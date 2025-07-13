Rails.application.routes.draw do
  get 'budgets/new'
  get 'budgets/create'
  get 'budgets/edit'
  get 'budgets/update'
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  root 'home#index'

  get 'signup', to: 'users#new', as: 'signup'
  post 'signup', to: 'users#create'

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  resource :budget, only: [:new, :create, :edit, :update]

end
