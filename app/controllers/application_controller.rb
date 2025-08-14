class ApplicationController < ActionController::Base
  helper_method :current_cart
  before_action :configure_permitted_parameters, if: :devise_controller?


  def current_cart
    if session[:cart_id]
      @current_cart ||= Cart.find_by(id: session[:cart_id])
      session[:cart_id] = nil unless @current_cart
    end

    if session[:cart_id].nil?
      @current_cart = Cart.create
      session[:cart_id] = @current_cart.id
    end

    @current_cart
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :avatar])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :avatar])
  end
end
