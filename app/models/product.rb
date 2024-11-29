class Product < ApplicationRecord
  # Validaciones
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Relaciones
  belongs_to :category
  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :order_products
  has_many :orders, through: :order_products

  def agotado?
    stock.to_i.zero?
  end

  # Método para restar stock de forma segura
  def reduce_stock!(quantity)
    if stock >= quantity
      self.stock -= quantity
      save!
    else
      raise "Stock insuficiente para #{name}"
    end
  end
end
