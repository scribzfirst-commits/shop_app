class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  belongs_to :user
#   enum status: { pending: "pending", paid: "paid", shipped: "shipped" }

  def calculate_total!
    self.total_price = order_items.sum { |oi| oi.price * oi.quantity }
    save!
  end

   def total_for_payment
    total_price.round(2).to_s
  end
  
end
