Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'users/registrations' }
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/mentions_legales', to: 'pages#mentions_legales', as: :mentions_legales
  get '/nous_decouvrir', to: 'pages#nous_decouvrir', as: :nous_decouvrir
  get '/tutoriel', to: 'pages#tutoriel', as: :turoriel

  resources :companies, only: [:new, :create, :index, :edit, :destroy, :update ]

  resources :companies do
    resources :buildings, only: [:new, :create, :index]
    # resources :apartments, only: [:new, :create, :index]
  end
  resources :buildings, only: [:new, :edit, :destroy, :update, :index ]

  resources :buildings do
    resources :apartments, only: [:index, :new, :create ]
    # resources :expenses, only: [:new, :create, :index]
  end
  resources :apartments, only: [:edit, :destroy, :update, :index, :new ]

  resources :expenses, only: [:edit, :destroy, :update, :new, :create, :index ]

  resources :apartments do
    resources :tenants, only: [:new, :create, :index]
  end
  resources :tenants, only: [:edit, :destroy, :update, :index]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :tenants, only: [ :index]
      resources :companies, only: [ :index]
      resources :buildings, only: [ :index]
    end
  end

  get '/waters/new', to: 'waters#index'
  get '/waters/:id', to: 'waters#index'
  get '/waters/edit/:id', to: 'waters#index'

  resources :waters, only: [:index]
  # get '/waters/new', to: '/waters#index'
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :waters, only: [ :index, :show, :create, :destroy, :update ]
    end
  end

  resources :tenants do
    resources :rents, only: [:new, :create, :index]
  end
  resources :rents, only: [:edit, :destroy, :update, :index, :new, :create]

  resources :buildings do
    resources :liasses, only: [:new, :create, :index]
  end
  resources :liasses, only: [:show, :edit, :destroy, :update, :index ]

end
