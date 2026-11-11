Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token

  resources :products, only: %i[ index new create ] do
    scope module: :products do
      resources :steps, only: %i[ show update ]
      resources :images, only: %i[ destroy ] do
        patch :move, on: :member
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "products#index"
end
