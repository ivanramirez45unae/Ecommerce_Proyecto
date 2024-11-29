Rails.application.routes.draw do
  get "contact/show"
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks"
  }
  # Ruta raíz de la aplicación
  root "home#index"
  get "about", to: "home#about", as: "about"
  get "contact", to: "contact#show"

  namespace :admin do
    get "stock", to: "products#stock", as: "stock"
    patch "products/:id/update_stock", to: "products#update_stock", as: "update_stock_product"
  end

  resources :orders, only: [ :index, :create ] do
    member do
      patch :change_status
    end
  end

  # Rutas para productos (index, show y favorito)
  resources :products, only: [ :index, :show, :edit, :update, :destroy, :new, :create ] do
    member do
      post "favorite"    # Agregar a favoritos
      delete "unfavorite" # Eliminar de favoritos
    end
  end

  resources :favorites, only: [ :index ]  # Ruta para listar los favoritos

  resources :categories, only: [ :show ]


  # Ruta para una acción add en el mismo controlador, que se usará para agregar productos al carrito.
  resource :cart, only: [ :show ] do
    post "add/:product_id", to: "carts#add", as: "add_to_cart"       # Agregar al carrito
    get "checkout", on: :member                                      # Página de checkout
    match "complete", to: "carts#complete", as: "complete_cart", via: [ :get, :post ] # Finalizar compra
    delete "remove/:product_id", to: "carts#remove", as: "remove_from_cart" # Eliminar del carrito
  end
end
