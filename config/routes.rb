Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    resources :fields, only: %i(index show)
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    get "/logout", to: "sessions#destroy"

    namespace :admin do
      resources :users, only: %i(index)
      resources :booking_fields, only: %i(index update)
      resources :fields, only: %i(new create edit update destroy) do
        member do
          get "status", to: "fields#status"
        end
      end
    end

    namespace :user do
      resource :profile, only: %i(show)
    end

    root "fields#index"
  end
end
