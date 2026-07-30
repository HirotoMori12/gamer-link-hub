Rails.application.routes.draw do
  root "home#index"

  # OAuth認証
  post "/auth/discord", as: :sign_in
  get "/auth/discord/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :sign_out

  # Guild管理
  resources :guilds, only: [:index] do
    member do
      post :select
    end
  end

  resources :posts, only: [:index, :show]

  # Discord Interactions
  namespace :discord do
    post "interactions", to: "interactions#create"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
