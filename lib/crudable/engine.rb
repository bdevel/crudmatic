module Crudable
  class Engine < ::Rails::Engine
    isolate_namespace Crudable
    
    # Configuration options
    config.crudable = ActiveSupport::OrderedOptions.new
    config.crudable.css_framework = :bootstrap  # Default to Bootstrap
    
    config.to_prepare do
      # Extend the placeholder helper with CrudableHelper functionality
      # This allows the main app to override or extend it further
      Crudable::ExtendableHelper.include(CrudableHelper) if defined?(CrudableHelper)
    end
  end
end
