# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  resources :rooms, only: %i[index show create] do
    resources :messages, only: %i[create]
  end

  resources :notifications, only: [] do
    collection do
      get 'count'
      get 'fetch_notifications'
      post 'mark_all_as_read'
      post 'delete_read'
    end
    post 'mark_as_read', on: :member
  end

  resources :sessions, only: %i[index new create destroy]

  resources :users do
    collection do
      get :search, controller: 'users', action: 'search'
      get :manage_registrations, controller: 'users', action: 'manage_registrations'
    end

    member do
      get :confirm_email, controller: 'users', action: 'confirm_email'
      post :approve
      post :reject
    end
  end

  resources :projects do
    get :search, controller: 'projects', action: 'search', on: :collection
  end

  resources :bids do
    member do
      post 'accept'
      post 'reject'
      patch 'files_upload'
    end
  end

  resources :categories, except: %i[show]

  root 'welcome#index'

  match '*path', to: 'application#render_not_found', constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }, via: :all
end
# rubocop:enable Metrics/BlockLength
