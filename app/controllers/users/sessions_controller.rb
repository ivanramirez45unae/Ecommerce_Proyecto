class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out current_user  # Usamos el método sign_out para cerrar sesión correctamente
    redirect_to "/users/sign_in", notice: "Sesión cerrada exitosamente"
  end
end
