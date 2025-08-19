class CategoriesController < ApplicationController
  include CrudableControllerMethods
  
  #crudable_controller_for Category
  #crudable_actions [:index, :show, :create, :update, :destroy]
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudableControllerMethods
end
