class Favorite < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :product

  # Validaciones para evitar duplicados
  validates :user_id, uniqueness: { scope: :product_id, message: "ya ha marcado este producto como favorito" }
end
