class CartsController < ApplicationController
    before_action :authenticate_user!

  def show
  @cart_items = current_cart.cart_items.includes(:product)
  end


  def add
    product = Product.find(params[:product_id])
    current_cart.add_product(product.id)
    redirect_to cart_path, notice: "#{product.name} added to cart!"
  end

  def remove
    item = current_cart.cart_items.find_by(product_id: params[:product_id])
    item.destroy if item
    redirect_to cart_path, notice: "Product removed from cart!"
  end

  def add_to_cart
    product = Product.find(params[:id])
    current_user.cart_items.create(product: product)
    redirect_to cart_path, notice: "#{product.name} added to your cart!"
  end

  def update
  cart_item = current_cart.cart_items.find_by(product_id: params[:id])
  if cart_item
    cart_item.update(quantity: params[:quantity])
  end
  head :ok
  end

end

