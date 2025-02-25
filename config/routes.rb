Rails.application.routes.draw do
  get "home/index"
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users

  resources :transactions do
    collection do
      get :monthly
      get :recurring
      get 'export_xml'
      get 'export_excel'
      post :import_excel
      delete :destroy_all
    end

    member do
      patch :stop_recurring #patch pq nao to criando e nem deletando nada
    end

  end

  resources :accounts
  resources :categories
  resource :account, only: [:show]

  # Root path route
  root "home#index"


  #################################################
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

end
