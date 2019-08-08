Rails.application.routes.draw do
  devise_for :users
  root "landing#show"
  get "/vehicles/search" => redirect("/vehicles")

  resources :vehicles, only: [:index] do
    collection do
      post :search
    end
  end
end
