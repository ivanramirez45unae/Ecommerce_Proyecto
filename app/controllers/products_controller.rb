class ProductsController < ApplicationController
  before_action :check_admin, only: [ :edit, :update ]

  def index
    if params[:query].present?
      @products = Product.where("name LIKE ?", "%#{params[:query]}%")
    else
      @products = Product.all
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def favorite
    @product = Product.find(params[:id])

    # Verifica si el producto ya está en los favoritos del usuario
    if current_user.favorite_products.include?(@product)
      flash[:alert] = "#{@product.name} Ya está en tus favoritos."
    else
      current_user.favorites.create(product: @product)
      flash[:notice] = "#{@product.name} Se agregó tus favoritos."
    end

    # Redirige de vuelta a la vista del producto
    redirect_to product_path(@product)
  end

  def unfavorite
    @product = Product.find(params[:id])

    # Elimina el producto de los favoritos del usuario
    if current_user.favorite_products.include?(@product)
      current_user.favorites.find_by(product: @product).destroy
      flash[:notice] = "#{@product.name} Ha sido eliminado de tus favoritos."
    else
      flash[:alert] = "#{@product.name} No estaba en tus favoritos."
    end

    # Redirige según el parámetro 'redirect_to_favorites'
    if params[:redirect_to_favorites]
      redirect_to favorites_path
    else
      redirect_to product_path(@product)
    end
  end

  # Acción para guardar el producto en la base de datos
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to root_path, notice: "Producto creado exitosamente."
    else
      flash[:error] = @product.errors.full_messages.join(", ")
      render :new
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      flash[:success] = "Producto eliminado correctamente."
      redirect_to root_path
    else
      flash[:error] = "No se pudo eliminar el producto."
      redirect_to root_path
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to root_path, notice: "Producto actualizado correctamente."
    else
      # Mostrar los errores en el formulario
      flash[:error] = @product.errors.full_messages.join(", ")
      render :edit
    end
  end

  private

  def check_admin
    redirect_to root_path, alert: "No tienes permisos para realizar esta acción." unless current_user&.admin?
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id, :image_url).tap do |whitelisted|
      # Limpiar y convertir el precio a un número entero
      whitelisted[:price] = whitelisted[:price].to_s.gsub(",", "").to_i
    end
  end
end
