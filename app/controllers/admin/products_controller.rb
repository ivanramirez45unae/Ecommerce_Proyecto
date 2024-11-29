class Admin::ProductsController < ApplicationController
  before_action :authenticate_admin! # Asegúrate de proteger estas rutas

  def stock
    @products = Product.all
  end

  def update_stock
    product = Product.find(params[:id])
    new_stock = params[:stock].to_i

    if new_stock >= 0
      product.update(stock: new_stock)
      flash[:notice] = "Stock actualizado correctamente."
    else
      flash[:alert] = "El stock no puede ser negativo."
    end

    redirect_to admin_stock_path
  end
end
