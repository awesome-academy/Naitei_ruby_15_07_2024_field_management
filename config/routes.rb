Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "field_list", to: "static_pages#field_list"

    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    get "/logout", to: "sessions#destroy"

    namespace :admin do
      resources :users, only: [:index]
    end

    namespace :user do
      resource :profile, only: [:show]
    end

    root "static_pages#field_list"
  end
end
