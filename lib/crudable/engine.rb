module Crudable
  class Engine < ::Rails::Engine
    isolate_namespace Crudable
    
    config.to_prepare do
      # Extend the placeholder helper with CrudableHelper functionality
      # This allows the main app to override or extend it further
      Crudable::ExtendableHelper.include(CrudableHelper) if defined?(CrudableHelper)
    end
  end
end
