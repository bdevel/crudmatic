module Crudmatic
  # TailwindForm - Form wrapper for Tailwind CSS framework
  #
  # This is a placeholder implementation for Tailwind CSS integration.
  # Host applications can extend this class to provide Tailwind-specific styling.
  #
  # USAGE EXAMPLE:
  # Create app/helpers/crudmatic/tailwind_form.rb in your host app:
  #
  #   module Crudmatic
  #     class TailwindForm < Crudmatic::TailwindForm
  #       def self.form_control_class
  #         'block w-full px-3 py-2 border border-gray-300 rounded-md'
  #       end
  #       
  #       def self.radio_group_class
  #         'space-y-2'
  #       end
  #       
  #       def self.radio_item_class
  #         'flex items-center'
  #       end
  #     end
  #   end
  #
  # To use TailwindForm instead of BootstrapForm, override the crud_edit_attr method
  # in your ExtendableHelper to use TailwindForm instead of BootstrapForm.
  #
  class TailwindForm
    attr_reader :form_builder, :helper_context
    
    def initialize(form_builder, helper_context = nil)
      @form_builder = form_builder
      @helper_context = helper_context
    end
    
    # Placeholder CSS class methods - override in host app
    def self.form_control_class
      ''  # Override with Tailwind classes
    end
    
    def self.form_control_radio_class
      ''  # Override with Tailwind classes
    end
    
    def self.radio_group_class
      ''  # Override with Tailwind classes
    end
    
    def self.radio_item_class
      ''  # Override with Tailwind classes
    end
    
    # Form field methods - by default just delegate to form_builder
    # Override in host app to add Tailwind classes
    def text_field(attr, options = {})
      form_builder.text_field(attr, options)
    end
    
    def text_area(attr, options = {})
      form_builder.text_area(attr, options)
    end
    
    def check_box(attr, options = {})
      form_builder.check_box(attr, options)
    end
    
    def number_field(attr, options = {})
      form_builder.number_field(attr, options)
    end
    
    def date_field(attr, options = {})
      form_builder.date_field(attr, options)
    end
    
    def datetime_field(attr, options = {})
      form_builder.datetime_field(attr, options)
    end
    
    def collection_select(attr, collection, value_method, text_method, select_options = {}, html_options = {})
      form_builder.collection_select(attr, collection, value_method, text_method, select_options, html_options)
    end
    
    def radio_button_group(attr, options, html_options = {})
      return '' unless helper_context
      
      # Basic implementation - override in host app for Tailwind styling
      helper_context.content_tag(:div, class: self.class.radio_group_class) do
        options.map do |option|
          helper_context.content_tag(:div, class: self.class.radio_item_class) do
            helper_context.content_tag(:label) do
              form_builder.radio_button(attr, option, { class: self.class.form_control_radio_class }.merge(html_options)) + " #{option}"
            end
          end
        end.join.html_safe
      end
    end
    
    # Delegate any missing methods to the original form builder
    def method_missing(method_name, *args, **kwargs, &block)
      if form_builder.respond_to?(method_name)
        form_builder.send(method_name, *args, **kwargs, &block)
      else
        super
      end
    end
    
    def respond_to_missing?(method_name, include_private = false)
      form_builder.respond_to?(method_name, include_private) || super
    end
  end
end