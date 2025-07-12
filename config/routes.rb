Rails.application.routes.draw do
  root 'home#index'
  get 'signup', to: 'users#new', as: 'signup'
  post 'signup', to: 'users#create'
end
