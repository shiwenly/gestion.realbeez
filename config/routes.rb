Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/mentions_legales', to: 'pages#mentions_legales', as: :mentions_legales
  get '/nous_decouvrir', to: 'pages#nous_decouvrir', as: :nous_decouvrir

  resources :companies, only: [:show, :new, :create, :index, :edit, :destroy, :update ]

  resources :companies do
    resources :buildings, only: [:new, :create]
  end
  resources :buildings, only: [:show, :edit, :destroy, :update ]

  resources :buildings do
    resources :apartments, only: [:new, :create]
  end
  resources :apartments, only: [:show, :edit, :destroy, :update ]

  resources :buildings do
    resources :expenses, only: [:new, :create]
  end
  resources :expenses, only: [:show, :edit, :destroy, :update ]

  resources :apartments do
    resources :tenants, only: [:new, :create]
  end
  resources :tenants, only: [:show, :edit, :destroy, :update ]

  resources :tenants do
    resources :waters, only: [:new, :create]
  end
  resources :waters, only: [:edit, :destroy, :update]

  resources :tenants do
    resources :rents, only: [:new, :create]
  end
  resources :rents, only: [:edit, :destroy, :update]

  resources :buildings do
    resources :liasses, only: [:new, :create]
  end
  resources :liasses, only: [:show, :edit, :destroy, :update ]

end
