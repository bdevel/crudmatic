module Crudable
  class RecordConfig
    attr_reader :model_class, :configs
    
    def initialize(model_class)
      @model_class = model_class
      @configs = {}
    end
    
    def add_config(type, *args)
      case type

      # store Record level configs on  @configs[type]
      when :index_attributes, :show_attributes, :edit_attributes, :search_attributes, :api_attributes, :pagination_limit, :index_order
        @configs[type] = args.first

      # Store attribute specific configs under  @configs[type][attr_name.to_sym]
      when :select_options, :input_note, :label, :dropdown, :radio
        attr_name = args.first
        value = args[1]
        @configs[type] ||= {}
        @configs[type][attr_name.to_sym] = value
      end
    end
    
    def get_attributes(type)
      base_attrs = case type
      when :index_attributes
        get_default_index_attributes
      when :show_attributes
        get_default_show_attributes
      when :edit_attributes
        get_default_editable_attributes
      when :search_attributes
        []
      when :api_attributes
        get_default_show_attributes
      else
        []
      end
      
      config = @configs[type]
      return base_attrs unless config
      
      if config.is_a?(Proc)
        config.call(base_attrs)
      elsif config.is_a?(Array)
        config
      else
        base_attrs
      end
    end
    
    def input_note_for(attr)
      # Handle Hash objects (associations) by extracting the key
      if attr.is_a?(Hash)
        attr = attr.keys.first
      end
      @configs.dig(:input_note, attr.to_sym)
    end
    
    def label_for(attr)
      # Handle Hash objects (associations) by extracting the key
      if attr.is_a?(Hash)
        attr = attr.keys.first
      end
      @configs.dig(:label, attr.to_sym)
    end
    
    def select_options_for(attr, record = nil)
      config = @configs.dig(:select_options, attr.to_sym) || 
               @configs.dig(:dropdown, attr.to_sym) ||
               @configs.dig(:radio, attr.to_sym)
      
      return nil unless config
      
      if config.is_a?(Proc)
        record ? config.call(record) : config.call(@model_class.new)
      else
        config
      end
    end
    
    def input_type_for(attr)
      return :radio if @configs.dig(:radio, attr.to_sym)
      return :select if @configs.dig(:dropdown, attr.to_sym) || @configs.dig(:select_options, attr.to_sym)
      
      # Fall back to column type inspection
      column = @model_class.columns.find { |c| c.name.to_s == attr.to_s }
      return column.type if column
      
      # Check for associations
      belongs_tos = @model_class.reflect_on_all_associations(:belongs_to).map(&:name)
      has_manys = @model_class.reflect_on_all_associations(:has_many).map(&:name)
      has_manys += @model_class.reflect_on_all_associations(:has_and_belongs_to_many).map(&:name)
      
      if belongs_tos.include?(attr.to_s.sub(/_id$/, '').to_sym)
        :belongs_to
      elsif has_manys.include?(attr.to_s.sub(/_ids$/, '').pluralize.to_sym)
        :has_many
      else
        :string
      end
    end
    
    def pagination_limit
      @configs[:pagination_limit] || 50
    end
    
    def index_order
      config = @configs[:index_order]
      return config if config
      
      # Default ordering logic (moved from controller)
      get_default_index_order
    end

    def permitted_attributes
      get_attributes(:edit_attributes).map do |attr|
        if attr.is_a?(Hash)
          # Handle association attributes like {parent: [:id, :name]}
          attr.keys.first
        else
          # Check if it's a has_many relationship that needs _ids
          manys = @model_class.reflect_on_all_associations(:has_many)
          manys += @model_class.reflect_on_all_associations(:has_and_belongs_to_many)
          
          assoc_name = attr.to_s.sub(/_ids$/, '').pluralize
          assoc = manys.find { |m| m.name.to_s == assoc_name }
          
          if assoc
            { "#{attr.to_s.singularize}_ids".to_sym => [] }
          else
            attr
          end
        end
      end
    end
    
    private
    
    def get_default_show_attributes
      cols = @model_class.columns.map { |c| c.name.to_sym } - [:id, :created_at, :updated_at]
      cols += [:created_at, :updated_at].select { |c| @model_class.columns.map(&:name).include?(c.to_s) }
      cols
    end
    
    def get_default_index_attributes
      cols = @model_class.columns.map { |c| c.name.to_sym } - [:id]
      texts = @model_class.columns.select { |c| c.type == :text }.map(&:name).map(&:to_sym)
      jsons = @model_class.columns.select { |c| c.type == :json }.map(&:name).map(&:to_sym)
      
      cols - [:created_at, :updated_at] - texts - jsons
    end
    
    def get_default_editable_attributes
      cols = @model_class.columns.map { |c| c.name.to_sym } - [:id, :created_at, :updated_at]
      jsons = @model_class.columns.select { |c| c.type == :json }.map(&:name).map(&:to_sym)
      cols - jsons
    end
    
    def get_default_index_order
      cols = @model_class.columns.map(&:name).map(&:to_sym)
      
      if cols.include?(:updated_at)
        { updated_at: :desc }
      elsif cols.include?(:created_at)
        { created_at: :desc }
      else
        { id: :desc }
      end
    end
  end
end
