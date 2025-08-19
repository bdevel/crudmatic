class AuthorsController < ApplicationController
  include CrudmaticControllerMethods
  
  crudmatic_controller_for Author
  crudmatic_actions [:index, :show, :create, :update, :destroy]
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudmaticControllerMethods
end