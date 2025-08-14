# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Product.create!([
  { name: "T-Shirt", description: "Cotton T-shirt", price: 19.99, stock: 50 },
  { name: "Jeans", description: "Blue denim jeans", price: 49.99, stock: 30 },
  { name: "Sneakers", description: "Running shoes", price: 79.99, stock: 20 },
  { name: "Joggers", description: "this is Joggers", price: 766.99, stock: 20 }
])
