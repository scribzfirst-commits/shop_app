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
  

  def placeorder

  end

  private

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id]) || Cart.create.tap do |cart|
      session[:cart_id] = cart.id
    end
  end
  
end
