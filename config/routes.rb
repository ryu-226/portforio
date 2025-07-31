Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, controllers: { registrations: 'users/registrations' }

  get 'mypage', to: "mypage#index", as: "mypage"

  get 'main', to: "main#index", as: "main"
  post 'main/draw', to: 'main#draw', as: 'draw_main'

  get 'history', to: "history#index", as: "history"

  get 'search', to: 'searches#index', as: :search

  post 'places/search', to: 'places#search'

  resource :budget, only: [:new, :create, :edit, :update]

  resources :draws, only: [:update]
end
