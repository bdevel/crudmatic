class BooksController < CrudableController
  self.model_class = Book
  
  # Optional: Override any methods if needed for custom behavior
  # For now, we'll use all the default CRUD actions from CrudableController
end