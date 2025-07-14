Rails.application.routes.draw do
  root 'home#index'

  get 'main', to: "main#index", as: "main"

  get 'mypage', to: "mypage#index", as: "mypage"

  get 'budgets/create'
  get 'budgets/edit'
  get 'budgets/update'

  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  get 'signup', to: 'users#new', as: 'signup'
  post 'signup', to: 'users#create'

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'

  delete 'logout', to: 'sessions#destroy', as: 'logout'

  resource :budget, only: [:new, :create, :edit, :update]

end
