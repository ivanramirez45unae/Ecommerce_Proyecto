class ApplicationController < ActionController::Base
  # Permitir navegadores modernos
  allow_browser versions: :modern

  # Establece el carrito para todas las acciones, excepto en Devise
  before_action :set_cart, unless: :devise_controller?

  # Configura parámetros adicionales para Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def authenticate_admin!
    redirect_to root_path, alert: "No tienes permiso para acceder a esta página." unless current_user&.admin?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ])
  end

  private

  def set_cart
    @cart = session[:cart] || []
  end
end
