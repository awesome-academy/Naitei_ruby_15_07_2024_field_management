Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    mount Sidekiq::Web => '/sidekiq'
    devise_for :users, controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
    }

    resources :users, only: %i(show)

    resources :fields, only: %i(index show) do
      member do
        get :favorite
        get :unfavorite
      end
    end

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
      get "/timeline", to: "activities#index"

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
