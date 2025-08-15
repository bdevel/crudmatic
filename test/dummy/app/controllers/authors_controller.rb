class AuthorsController < CrudableController
  self.model_class = Author
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudableController
end