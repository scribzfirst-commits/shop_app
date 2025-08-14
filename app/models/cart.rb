class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  def add_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    if item
      item.quantity += 1
    else
      item = cart_items.build(product_id: product_id, quantity: 1)
    end
    item.save
  end
end
