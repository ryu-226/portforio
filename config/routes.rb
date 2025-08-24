Rails.application.routes.draw do
  root 'home#index'

  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions',
               omniauth_callbacks: "users/omniauth_callbacks"
             }

  # 画面系
  get  'mypage',  to: "mypage#index",   as: "mypage"
  get  'main',    to: "main#index",     as: "main"
  post 'main/draw', to: 'main#draw',    as: 'draw_main'
  get  'history', to: "history#index",  as: "history"
  get  'search',  to: 'searches#index', as: :search

  # API/処理系
  post 'places/search', to: 'places#search'

  # resource(s)
  resource  :budget,  only: [:new, :create, :edit, :update]
  resource  :contact, only: [:new, :create]
  resources :draws, only: [:show, :update]

  get "/terms",   to: "static#terms",   as: :terms
  get "/privacy", to: "static#privacy", as: :privacy

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
