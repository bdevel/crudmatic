class CategoriesController < CrudableController
  self.model_class = Category
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudableController
end