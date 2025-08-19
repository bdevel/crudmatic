# Example usage of CrudmaticRecord
class ProtectedAsset < ApplicationRecord
  include CrudmaticRecord
  
  # Configure which attributes appear on different pages
  crudmatic :index_attributes,  proc {|attrs|  attrs - [:id, :description] } # index page
  crudmatic :show_attributes,   proc {|attrs|  attrs.concat([:id, {parent: [:id, :name]}]) } # associations are passed as a Hash
  crudmatic :edit_attributes,   [:name, :description]
  crudmatic :search_attributes, [:name, :description]
  crudmatic :api_attributes,    [:id, :name, :description, :parent]
  
  # Provide select tag options as an array or a proc which will pass the model instance
  crudmatic :select_options, :status, %w{active disabled}
  crudmatic :input_note, :status, "Here is a note for the user"
  crudmatic :label, :status, "Item Status"
  
  crudmatic :dropdown, :city, proc {|m| m.state.cities }
  crudmatic :radio, :gender, %w{male female other}
end

# Usage examples:
# ProtectedAsset.crudmatic_config.get_attributes(:index_attributes)
# ProtectedAsset.crudmatic_config.input_note_for(:status)
# ProtectedAsset.crudmatic_config.select_options_for(:status, @record)

# my_asset_instance.crudmatic_config.label_for(:status)
# my_asset_instance.crudmatic_config.input_type_for(:gender) # returns :radio