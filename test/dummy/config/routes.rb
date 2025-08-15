Rails.application.routes.draw do
  mount Crudable::Engine => "/crudable"
  
  # Library Management System routes
  resources :books do
    member do
      patch :bulk
    end
  end
  
  resources :authors do
    member do
      patch :bulk
    end
  end
  
  resources :categories do
    member do
      patch :bulk
    end
  end
  
  # Set books as the root path
  root 'books#index'
end
