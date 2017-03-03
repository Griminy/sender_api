Rails.application.routes.draw do
  
  namespace :api do
    resources :messages, only: :create
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
