Rails.application.routes.draw do
  root 'home#index'

  devise_for :users,
             controllers: { registrations: 'users/registrations', sessions: 'users/sessions',
                            omniauth_callbacks: "users/omniauth_callbacks" }

  get 'mypage', to: "mypage#index", as: "mypage"

  get 'main', to: "main#index", as: "main"
  post 'main/draw', to: 'main#draw', as: 'draw_main'

  get 'history', to: "history#index", as: "history"

  get 'search', to: 'searches#index', as: :search

  post 'places/search', to: 'places#search'

  resource :budget, only: [:new, :create, :edit, :update]

  resource :contact, only: [:new, :create]

  resources :draws, only: [:show]
  authenticate :user do
    resources :draws, only: [:update]
  end

  get "/terms", to: "static#terms", as: :terms
  get "/privacy", to: "static#privacy", as: :privacy

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
