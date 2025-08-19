module Crudable
  # BootstrapForm - Customizable form wrapper for different CSS frameworks
  #
  # This class wraps Rails form builders and provides framework-specific CSS classes.
  # Host applications can override this class to use different CSS frameworks.
  #
  # CUSTOMIZATION EXAMPLE:
  # Create app/helpers/crudable/bootstrap_form.rb in your host app:
  #
  #   module Crudable
  #     class BootstrapForm < Crudable::BootstrapForm
  #       def self.form_control_class
  #         'my-custom-input-class'  # Instead of 'form-control'
  #       end
  #       
  #       def self.radio_group_class
  #         'my-radio-group'  # Instead of 'radio-group'
  #       end
  #     end
  #   end
  #
  # FOR OTHER FRAMEWORKS (Tailwind, Bulma, etc.):
  # Override all class methods to return appropriate CSS classes.
  #
  class BootstrapForm
    attr_reader :form_builder, :helper_context
    
    def initialize(form_builder, helper_context = nil)
      @form_builder = form_builder
      @helper_context = helper_context
    end
    
    # CSS class configuration - can be overridden by host app
    def self.form_control_class
      'form-control'
    end
    
    def self.form_control_radio_class
      'form-control-radio'
    end
    
    def self.radio_group_class
      'radio-group'
    end
    
    def self.radio_item_class
      'radio'
    end
    
    # Form field methods with Bootstrap classes
    def text_field(attr, options = {})
      form_builder.text_field(attr, { class: self.class.form_control_class }.merge(options))
    end
    
    def text_area(attr, options = {})
      form_builder.text_area(attr, { class: self.class.form_control_class }.merge(options))
    end
    
    def check_box(attr, options = {})
      form_builder.check_box(attr, { class: '' }.merge(options))
    end
    
    def number_field(attr, options = {})
      form_builder.number_field(attr, { class: self.class.form_control_class }.merge(options))
    end
    
    def date_field(attr, options = {})
      form_builder.date_field(attr, { class: self.class.form_control_class }.merge(options))
    end
    
    def datetime_field(attr, options = {})
      form_builder.datetime_field(attr, { class: self.class.form_control_class }.merge(options))
    end
    
    def collection_select(attr, collection, value_method, text_method, select_options = {}, html_options = {})
      form_builder.collection_select(
        attr, 
        collection, 
        value_method, 
        text_method, 
        select_options, 
        { class: self.class.form_control_class }.merge(html_options)
      )
    end
    
    def radio_button_group(attr, options, html_options = {})
      return '' unless helper_context
      
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