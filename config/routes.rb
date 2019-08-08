Rails.application.routes.draw do
  root "landing#show"
  get "/vehicles/search" => redirect("/vehicles")

  resources :vehicles, only: [:index] do
    collection do
      post :search
    end
  end
end
