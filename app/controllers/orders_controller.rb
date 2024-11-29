class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, only: [ :index, :change_status ]

  def index
    @orders = Order.includes(:order_products).all
  end

  def change_status
    @order = Order.find(params[:id]) # Encuentra la orden por su ID
    @order.status = !@order.status  # Alterna entre `true` y `false`

    if @order.save
      redirect_to orders_path, notice: "Estado de la orden actualizado exitosamente."
    else
      redirect_to orders_path, alert: "Hubo un error al cambiar el estado."
    end
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.total = calculate_total
    @order.status = false

    # Verificar stock y restar
    @order.products.each do |product|
      cantidad_solicitada = params[:quantities][product.id.to_s].to_i
      if cantidad_solicitada > product.stock
        flash[:alert] = "Stock insuficiente para #{product.name}."
        redirect_to cart_path and return
      end
    end

    if @order.save
      @order.products.each do |product|
        cantidad_solicitada = params[:quantities][product.id.to_s].to_i
        if cantidad_solicitada > 0
          product.update!(stock: product.stock - cantidad_solicitada)
        end
      end
      redirect_to thank_you_path, notice: "¡Compra exitosa!"
    else
      flash.now[:alert] = "Corrige los errores."
      render :new
    end
  end


  private

  def order_params
    params.require(:order).permit(:nombre, :apellido, :email, :telefono, :pais, :ciudad, :departamento, :calle)
  end

  def calculate_total
    @cart.sum { |item| Product.find(item["product_id"]).price * item["quantity"] }
  end

  def save_order_products(order)
    @cart.each do |item|
      product = Product.find(item["product_id"])
      OrderProduct.create!(order: order, product: product, quantity: item["quantity"])
    end
  end

  def admin_only
    redirect_to root_path, alert: "No tienes acceso a esta sección." unless current_user.admin?
  end
end
