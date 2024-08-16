Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    resources :fields, only:[:index, :show]
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    get "/logout", to: "sessions#destroy"

    namespace :admin do
      resources :users, only: [:index]
      resources :booking_fields, only: [:index, :update]
      resources :fields, only: [:new, :create] do
        member do
          get "status", to: "fields#status"
        end
      end
    end

    namespace :user do
      resource :profile, only: [:show]
    end

    root "fields#index"
  end
end
