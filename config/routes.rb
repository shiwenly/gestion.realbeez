Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :companies, only: [:show, :new, :create, :index, :edit, :destroy, :update ]

  resources :companies do
    resources :buildings, only: [:new, :create]
  end
  resources :buildings, only: [:show, :edit, :destroy, :update ]

  resources :buildings do
    resources :apartments, only: [:new, :create]
  end
  resources :apartments, only: [:show, :edit, :destroy, :update ]

end
