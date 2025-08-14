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
