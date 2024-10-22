# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#new'
  resources :sessions, only: %i[new create show] do
    resources :media, only: %i[create destroy]
    resources :playlists, only: %i[create destroy]
  end
end
