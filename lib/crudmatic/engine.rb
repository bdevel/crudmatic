module Crudmatic
  class Engine < ::Rails::Engine
    isolate_namespace Crudmatic
    
    # Configuration options
    config.crudmatic = ActiveSupport::OrderedOptions.new
    config.crudmatic.css_framework = :bootstrap  # Default to Bootstrap
    
    config.to_prepare do
      # Extend the placeholder helper with CrudmaticHelper functionality
      # This allows the main app to override or extend it further
      Crudmatic::ExtendableHelper.include(CrudmaticHelper) if defined?(CrudmaticHelper)
    end
  end
end