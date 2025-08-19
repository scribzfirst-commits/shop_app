class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @order = Order.new
    @cart = current_cart
  end

  def create
  total = params[:grand_total].to_f # Use value sent from the cart page

  @order = current_user.orders.build(total_price: total)

  if @order.save
    current_cart.cart_items.each do |item|
      @order.order_items.create!(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    # Empty the cart after order creation
    current_cart.cart_items.destroy_all

    redirect_to payment_order_path(@order), notice: "Order created successfully."
  else
    redirect_to cart_path, alert: "There was a problem creating your order."
  end
  end

  def show
    @order = Order.find(params[:id])
  end

  def payment
    @order = current_user.orders.find(params[:id])
    @order_total = @order.total_price # Always comes from DB now
  end


  def orderhistory
    @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
  end
  def destroy
    @order = current_user.orders.find_by(id: params[:id])

    if @order.nil?
      redirect_to orderhistory_orders_path, alert: "Order not found."
    elsif @order.status == "paid"
      redirect_to orderhistory_orders_path, alert: "Paid orders cannot be deleted."
    else
      @order.destroy
      redirect_to orderhistory_orders_path, notice: "Order deleted successfully."
    end
  end

  def invoice
  @order = Order.find(params[:id])

  respond_to do |format|
    format.pdf do
      font_path = Rails.root.join("app/assets/fonts")

      pdf = Prawn::Document.new

      # Register your font family
      pdf.font_families.update(
        "DejaVuSans" => {
          normal: font_path.join("DejaVuSans.ttf"),
          bold:   font_path.join("DejaVuSans-Bold.ttf")
        }
      )

      pdf.font "DejaVuSans"

      # Header
      pdf.text "🧾 Order Receipt", size: 24, style: :bold, align: :center
      pdf.move_down 20

      # Order details
      pdf.text "Order ID: #{@order.id}"
      pdf.text "Status: #{@order.status.capitalize}"
      pdf.text "Total: ₹#{sprintf('%.2f', @order.total_price)}"
      pdf.move_down 20

      # Table for items
      items = [["Product", "Price", "Quantity", "Subtotal"]]
      @order.order_items.each do |item|
        items << [
          item.product&.name || "Deleted Product",
          "₹#{sprintf('%.2f', item.price)}",
          item.quantity,
          "₹#{sprintf('%.2f', item.price * item.quantity)}"
        ]
      end
      items << ["", "", "Grand Total", "₹#{sprintf('%.2f', @order.total_price)}"]

      pdf.table(items, header: true, width: 500)

      send_data pdf.render,
                filename: "order_#{@order.id}_invoice.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end
end


  private

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id]) || Cart.create.tap do |cart|
      session[:cart_id] = cart.id
    end
  end

  def complete_payment
    @order = current_user.orders.find(params[:id])
    @order.update(status: "paid")
    redirect_to root_path, notice: "Payment successful!"
  end


end
