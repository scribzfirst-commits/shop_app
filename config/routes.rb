Rails.application.routes.draw do
  devise_for :users
  
  root "home#index"
  
  get "edituser", to: "home#edituser", as: :edituser
  patch "updateuser", to: "home#updateuser", as: :update_user



  resources :products, only: [:index, :show]
  
  resource :cart, only: [:show] do
    post "add/:product_id", to: "carts#add", as: :add_to
    post "remove/:product_id", to: "carts#remove", as: :remove_from
  end

  resources :orders, only: [:new, :create, :show, :destroy] do
    member do
      get :payment
      post :complete_payment
      get :placeorder
      get :invoice
    
    end
    collection do
      get :orderhistory
    end
  end

  resources :payments, only: [:create] do
  collection do
    get :complete
    get :placeorder
  end
end
end
