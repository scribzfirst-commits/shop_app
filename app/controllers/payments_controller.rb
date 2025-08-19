class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def complete
    order = Order.find_by(id: params[:order_id])

    unless order && order.user == current_user
      redirect_to root_path, alert: "Order not found." and return
    end

    # Optionally, mark order as paid here
    order.update(status: "paid") if order.respond_to?(:status)

    # Clear the cart in the backend
    current_cart.cart_items.destroy_all

    # Deliver the email with attached PDF. Use deliver_now in dev so letter_opener opens immediately.
    PaymentMailer.payment_receipt(current_user, order,).deliver_now

     redirect_to placeorder_payments_path, notice: "Payment completed. Receipt sent to #{current_user.email}."

  end
  
  def create
    order = Order.find(params[:order_id])
    return redirect_to root_path, alert: "Order not found" unless order

    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: { payment_method: "paypal" },
      transactions: [{
        amount: {
          total: order.total_for_payment,   # FIXED here
          currency: "USD"
        },
        description: "Order ##{order.id} Payment"
      }],
      redirect_urls: {
        return_url: complete_payments_url(order_id: order.id),
        cancel_url: root_url
      }
    })

    if payment.create
    approval_url = payment.links.find { |v| v.rel == "approval_url" }.href
       redirect_to approval_url, allow_other_host: true
    else
     redirect_to root_path, alert: "Error creating PayPal payment: #{payment.error.inspect}"
    end

  end



  def placeorder

  end

  private

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id]) || Cart.create.tap do |cart|
      session[:cart_id] = cart.id
    end
  end
  
end
