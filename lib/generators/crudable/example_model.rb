# Example usage of CrudableRecord
class ProtectedAsset < ApplicationRecord
  include CrudableRecord
  
  # Configure which attributes appear on different pages
  crudable :index_attributes,  proc {|attrs|  attrs - [:id, :description] } # index page
  crudable :show_attributes,   proc {|attrs|  attrs.concat([:id, {parent: [:id, :name]}]) } # associations are passed as a Hash
  crudable :edit_attributes,   [:name, :description]
  crudable :search_attributes, [:name, :description]
  crudable :api_attributes,    [:id, :name, :description, :parent]
  
  # Provide select tag options as an array or a proc which will pass the model instance
  crudable :select_options, :status, %w{active disabled}
  crudable :input_note, :status, "Here is a note for the user"
  crudable :label, :status, "Item Status"
  
  crudable :dropdown, :city, proc {|m| m.state.cities }
  crudable :radio, :gender, %w{male female other}
end

# Usage examples:
# ProtectedAsset.crudable_config.get_attributes(:index_attributes)
# ProtectedAsset.crudable_config.input_note_for(:status)
# ProtectedAsset.crudable_config.select_options_for(:status, @record)

# my_asset_instance.crudable_config.label_for(:status)
# my_asset_instance.crudable_config.input_type_for(:gender) # returns :radio