# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :session, only: %i[new create destroy]
  resources :users, only: %i[new create]

  resources :companies do
    resources :contacts, except: [:index]
  end

  resources :contacts, only: [:index]
  resources :deals
  resources :activities, only: %i[index new create show edit update destroy]

  # Email Providers
  resources :email_providers do
    member do
      post :test_connection
      post :set_default
    end
  end

  # Segments
  resources :segments do
    member do
      post :add_contacts
      delete :remove_contact
    end
  end

  # Campaigns
  resources :campaigns do
    member do
      post :send_campaign
      get  :preview
      post :duplicate
    end
  end

  namespace :api do
    namespace :v1 do
      resources :companies
      resources :contacts
      resources :deals
      resources :activities
    end
  end
end
