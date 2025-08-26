module CrudmaticRecord
  extend ActiveSupport::Concern

  included do
    # Instance method to access crudmatic config
    def crudmatic_config
      self.class.crudmatic_config
    end
  end

  # Instance methods (similar to existing crud_attributes.rb)
  
  # for papertrail gem
  # def version_changes
  #   if self.respond_to?(:versions)
  #     self.versions.sort_by(&:created_at).reverse.map do |v|
  #       {event: v.event,
  #        changes: (v.object_changes || []).map{|c| c.to_a.flatten}.map{|cc| {attribute: cc[0], old_value: cc[1], new_value: cc[2]}},
  #        info:  {created_at: v.created_at, who: v.whodunnit}
  #       }
  #     end
  #   else
  #     []
  #   end
  # end
  
  # for dropdown. Defaults to all records. Override with XXX_selection_options
  def select_options_for_belongs_to(name)
    fn = "#{name}_select_options"
    if respond_to?(fn)
      send(fn)
    else
      a = self.class.reflect_on_all_associations(:belongs_to).select{|a| a.name.to_s == name.to_s}.first
      return [] unless a
      
      # Safely resolve the association class
      begin
        klass = a.klass
      rescue NameError => e
        # Try to constantize the class_name if klass fails
        begin
          klass = a.class_name.constantize
        rescue NameError
          Rails.logger.warn "Could not resolve association class for #{name}: #{e.message}"
          return []
        end
      end
      
      scope = klass.all
      scope = apply_default_sort_to_scope(scope, klass)
      scope
    end
  end

  # for checkbox list. Defaults to all records. Override with XXX_selection_options
  def select_options_for_has_many(name)
    fn = "#{name}_select_options"
    if respond_to?(fn)
      send(fn)
    else
      manys = self.class.reflect_on_all_associations(:has_many)
      manys += self.class.reflect_on_all_associations(:has_and_belongs_to_many)
      
      a = manys.select{|a| a.name.to_s == name.to_s.pluralize}.first
      model = a.name.to_s.singularize.classify.constantize
      
      if model.respond_to?(:all)
        scope = model.all
        scope = apply_default_sort_to_scope(scope, model)
      else
        raise "Cannot find model for relationship #{name.inspect} on #{self.class.inspect}"
      end
      scope
    end
  end

  def apply_default_sort_to_scope(scope, klass)
    cols = klass.columns.map(&:name)
    # pick which column to order by
    if cols.include?("title")
      scope = scope.order(title: :asc)
    elsif cols.include?("name")
      scope = scope.order(name: :asc)
    end
    scope
  end
  
  def to_s
    out = nil
    out = send(:title) if out.nil? && self.respond_to?(:title)
    out = send(:name) if out.nil? && self.respond_to?(:name)
    
    if out.nil?
      # use first string attributes
      a = self.class.columns.select{|c| c.name.to_s != 'id' && c.type == :string && self.send(c.name).present?}.first
      if a.present?
        out = send(a.name)
      else
        # no string columns i guess, use the ID
        out = self.class.to_s + " ##{self.id}"
      end
    end
    out
  end

  def to_param
    id.to_s
  end

  class_methods do
    def to_s
      model_name.singular.titleize
    end

    # Main crudmatic method to configure the model
    def crudmatic(type, *args)
      crudmatic_config.add_config(type, *args)
    end

    # Access to the config object
    def crudmatic_config
      @crudmatic_config ||= Crudmatic::RecordConfig.new(self)
    end

    # Backward compatibility methods that delegate to the config
    def show_attributes
      crudmatic_config.get_attributes(:show_attributes)
    end

    def index_attributes
      crudmatic_config.get_attributes(:index_attributes)
    end
    
    def editable_attributes
      crudmatic_config.get_attributes(:edit_attributes)
    end

    def bulk_editable_attributes
      crudmatic_config.get_attributes(:bulk_editable_attributes)
    end

    def api_attributes
      crudmatic_config.get_attributes(:api_attributes)
    end

    def search_attributes
      crudmatic_config.get_attributes(:search_attributes)
    end

    def filter_attributes
      crudmatic_config.get_attributes(:filter_attributes)
    end

    def permitted_attributes
      crudmatic_config.permitted_attributes
    end
  end
end
