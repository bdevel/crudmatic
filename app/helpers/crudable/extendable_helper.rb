module Crudable
  module ExtendableHelper
    # Extendable helper pattern for Rails engines
    #
    # WHY THIS EXISTS:
    # When using mixin-based controllers (include CrudableControllerMethods), 
    # calling `helper CrudableHelper` inside the concern's `included` block 
    # doesn't work reliably due to Rails' timing/context issues with helper 
    # inclusion from within concerns.
    #
    # SOLUTION:
    # This empty placeholder module gets extended by the main app, which then
    # includes the actual CrudableHelper functionality. The controller can 
    # reliably reference this module since it's file-based, not concern-based.
    #
    # USAGE IN MAIN APP:
    # Create app/helpers/crudable/extendable_helper.rb:
    #
    #   module Crudable
    #     module ExtendableHelper
    #       include CrudableHelper    # Include engine's helper functionality
    #       include YourOtherHelpers  # Optional: add other helpers
    #       
    #       def your_custom_method
    #         # Add custom helper methods or override existing ones
    #       end
    #     end
    #   end
    #
    # This pattern sidesteps Rails' limitation where `helper` calls inside 
    # concern `included` blocks don't work properly.
  end
end