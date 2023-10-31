Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :countries, param: :name, except: [:edit]

  resources :users, param: :name, except: [:edit]

  resource :user_by_id,
    path: 'users/by-id/:id',
    param: :id,
    controller: 'user_by_id',
    only: [:show, :update, :destroy]

  post 'rename/countries/:name', to: 'countries#rename'
  post 'rename/users/:name',     to: 'users#rename'
end
