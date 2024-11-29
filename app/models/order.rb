class Order < ApplicationRecord
  belongs_to :user
  has_many :order_products
  has_many :products, through: :order_products

  validates :nombre, :apellido, :email, :telefono, :pais, :ciudad, :departamento, :calle, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  validates :telefono, format: { with: /\A\d{9,15}\z/, message: "debe ser un número entre 9 y 15 dígitos" }
end
