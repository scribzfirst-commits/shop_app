class AddTotalAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :total_amount, :decimal
  end
end
