Rails.application.routes.draw do
  root 'landing#show'

  resources :vehicles, only: [:index, :show]
  post '/vehicles', to: 'vehicles#index'
end
