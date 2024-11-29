class User < ApplicationRecord
  # Método para verificar si el usuario es administrador
  def admin?
    role == "admin"
  end

  # Relaciones
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product
  has_many :orders

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
