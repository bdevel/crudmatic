Rails.application.routes.draw do
  mount Crudable::Engine => "/crudable"
  
  # Library Management System routes
  resources :books do
    patch(:bulk, on: :collection)
  end
  
  resources :authors do
    collection do
      patch :bulk
    end
  end
  
  resources :categories do
    collection do
      patch :bulk
    end
  end
  
  # Set books as the root path
  root 'books#index'
end
