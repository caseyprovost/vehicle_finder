Rails.application.routes.draw do
  devise_for :users
  root "landing#show"
  get "/vehicles/search" => redirect("/vehicles")

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :vehicles, only: [:index] do
    collection do
      post :search
    end
  end

  resources :user_vehicles, only: [:create]
end
