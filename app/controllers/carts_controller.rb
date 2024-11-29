class CartsController < ApplicationController
  def show
    @cart = session[:cart] || []  # Si no hay carrito, se inicializa como un array vacío
  end

  def add
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i
    session[:cart] ||= []  # Si no existe un carrito, se inicializa como un array vacío

    # Busca si el producto ya está en el carrito
    existing_product = session[:cart].find { |item| item["product_id"] == product_id }

    if existing_product
      # Si ya está, suma la cantidad
      existing_product["quantity"] += quantity
    else
      # Si no está, agrega un nuevo hash con el producto y la cantidad
      session[:cart] << { "product_id" => product_id, "quantity" => quantity }
    end

    redirect_to cart_path, notice: "Producto agregado al carrito."  # Redirige al carrito con un mensaje
  end

  def remove
    product_id = params[:product_id].to_s
    session[:cart] ||= []  # Si no existe un carrito, se inicializa como un array vacío

    # Elimina el producto del carrito
    session[:cart].reject! { |item| item["product_id"] == product_id }

    redirect_to cart_path, notice: "Producto eliminado del carrito."  # Redirige al carrito con un mensaje
  end

  def checkout
    @cart = session[:cart] || []
    # Verifica si el carrito está vacío
    if @cart.empty?
      redirect_to cart_path, alert: "Tu carrito está vacío. Agrega productos antes de continuar."  # Si el carrito está vacío, se redirige
    end
  end

  def complete
    @cart = session[:cart] || []

    # Verifica si el carrito está vacío
    if @cart.empty?
      redirect_to cart_path, alert: "Tu carrito está vacío. Agrega productos antes de continuar."
      return
    end

    ActiveRecord::Base.transaction do
      # Iterar sobre los productos en el carrito para validar y restar stock
      @cart.each do |item|
        product = Product.find(item["product_id"])
        quantity = item["quantity"]

        # Validar si hay suficiente stock disponible
        if product.stock < quantity
          flash[:alert] = "El stock para #{product.name} no es suficiente."
          redirect_to cart_path and return
        end

        # Restar el stock y guardar
        product.stock -= quantity
        product.save!
      end

      # Crear la orden con los datos del usuario y otros detalles
      @order = Order.create!(
        user_id: current_user.id,
        total: calculate_total,
        status: 0, # Estado inicial de la orden (0 = pendiente)
        nombre: params[:nombre],
        apellido: params[:apellido],
        email: params[:email],
        telefono: params[:telefono],
        pais: params[:pais],
        ciudad: params[:ciudad],
        departamento: params[:departamento],
        calle: params[:calle]
      )

      # Asociar productos a la orden
      @cart.each do |item|
        product = Product.find(item["product_id"])
        @order.order_products.create!(
          product: product,
          quantity: item["quantity"]
        )
      end

      # Vaciar el carrito
      session[:cart] = []

      # Redirigir con mensaje de éxito
      flash[:notice] = "¡Gracias por tu compra! Tu orden ha sido registrada exitosamente."
      redirect_to root_path
    end
  rescue ActiveRecord::RecordInvalid => e
    # Manejar errores en la transacción
    flash[:alert] = "Hubo un problema al procesar tu compra: #{e.message}"
    redirect_to cart_path
  end


  private

  def calculate_total
    # Método para calcular el total del carrito
    @cart.sum do |item|
      product = Product.find(item["product_id"])
      product.price * item["quantity"]
    end
  end
end
