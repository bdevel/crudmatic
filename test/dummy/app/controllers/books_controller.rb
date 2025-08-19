class BooksController < ApplicationController
  include CrudableControllerMethods
  
  crudable_controller_for Book
  crudable_actions [:index, :show, :create, :update, :destroy, :bulk_edit]
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudableControllerMethods
end
