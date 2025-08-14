class ProductsController < ApplicationController

  def index
    if params[:q].present?
      @products = Product.where("name LIKE ?", "%#{params[:q]}%")
    else
      @products = Product.all
    end
  end


  def show
    @product = Product.find(params[:id])
  end
end
