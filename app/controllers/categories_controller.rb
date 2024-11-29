class CategoriesController < ApplicationController
  def show
    # Encuentra la categoría principal o subcategoría
    @category = Category.find(params[:id])

    # Obtén los productos asociados a esta categoría
    @products = Product.where(category_id: @category.id)
  end
end
