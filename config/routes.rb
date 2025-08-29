# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#new'
  resources :sessions, only: %i[new create show] do
    member do
      patch :play_next
    end
    resources :media, only: %i[create destroy] do
      member do
        patch :play_next
        patch :pause
        patch :resume  
        patch :restart
      end
    end
    resources :playlists, only: %i[create destroy] do
      member do
        patch :play_next
      end
    end
  end
end
