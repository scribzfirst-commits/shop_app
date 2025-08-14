class Product < ApplicationRecord
  has_many :cart_items
  has_many :order_items
    
  validates :name, :price, :stock, presence: true
end
