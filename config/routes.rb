# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#new'
  resources :sessions, only: %i[new create show] do
    resources :media, only: [:create]
    resources :playlists, only: %i[create destroy]
  end
end
