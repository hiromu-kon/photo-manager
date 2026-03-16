Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  resources :photos, only: [:index]
end
