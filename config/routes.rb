Rails.application.routes.draw do
  root 'home#index'

  get 'signup', to: 'users#new', as: 'signup'
  post 'signup', to: 'users#create'

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'

  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'mypage', to: "mypage#index", as: "mypage"

  get 'main', to: "main#index", as: "main"
  post 'main/draw', to: 'main#draw', as: 'draw_main'

  resource :budget, only: [:new, :create, :edit, :update]

end
