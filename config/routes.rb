Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    mount Sidekiq::Web => '/sidekiq'

    resources :fields, only: %i(index show) do
      member do
        get :favorite
        get :unfavorite
      end
    end
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    get "/logout", to: "sessions#destroy"

    resources :users, only: %i(show create new)

    resources :account_activations, only: %i(edit)

    namespace :admin do
      resources :users, only: %i(index destroy)
      resources :booking_fields, only: %i(index update)
      resources :fields, only: %i(new create edit update destroy) do
        member do
          get "status", to: "fields#status"
        end
      end
      resources :vouchers, only: %i(index new create)
    end

    namespace :user do
      resources :users, only: %i(show update edit)
      resources :booking_fields, only: %i(new create pay update) do
        member do
          get :pay
          get :demo_payment
        end
        collection do
          get :export
          get :export_status
          get :export_download
        end
      end
      get "/history", to: "booking_fields#index"
      get "/timeline", to: "dashboards#index"

      resources :ratings, only: %i(create destroy) do
        resources :comments, only: :create
      end

      resources :fields, only: %i(show) do
        resources :ratings, only: %i(create destroy) 
      end
    end

    root "fields#index"
  end
end
