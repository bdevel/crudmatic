module CrudableControllerMethods
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    #helper Crudable::ExtendableHelper
    
    before_action :set_record, only: [:show, :edit, :update, :destroy]

    class_attribute :_crudable_model_class
    class_attribute :_crudable_actions
    class_attribute :_crudable_search_attributes
    
    # Set defaults
    self._crudable_actions = [:index, :show, :create, :update, :destroy, :bulk_edit]
  end

  class_methods do
    def crudable_controller_for(model_class)
      self._crudable_model_class = model_class
    end

    def crudable_actions(actions_array)
      self._crudable_actions = actions_array
    end

    def crudable_search_attributes(attrs_array)
      self._crudable_search_attributes = attrs_array
    end
  end

  # GET
  def index
    @records = records_scope
    
    # Apply ordering using the new config system
    @records = @records.order(index_order)

    @records = apply_search_params(@records)
    
    # Apply pagination using offset
    @total_count     = @records.count
    @offset          = params[:offset].to_i
    @limit           = pagination_limit
    @records         = @records.offset(@offset).limit(@limit)
    
    # Calculate pagination info
    @current_page    = (@offset / @limit) + 1
    @total_pages     = (@total_count.to_f / @limit).ceil
    @has_previous    = @offset > 0
    @has_next        = @offset + @limit < @total_count
    @previous_offset = [@offset - @limit, 0].max
    @next_offset     = @offset + @limit
    
    # Set attributes for views
    @attributes = model_class.respond_to?(:index_attributes) ? model_class.index_attributes : []
    
    render_with_engine_fallback
  end

  def show
    unless crud_actions.include?(:show)
      raise ActionController::RoutingError.new("Show action not allowed")
    end
    render_with_engine_fallback
  end

  def new
    unless crud_actions.include?(:create)
      raise ActionController::RoutingError.new("New record action not allowed")
    end

    @record = model_class.new
    render_with_engine_fallback
  end

  def edit
    unless crud_actions.include?(:update)
      raise ActionController::RoutingError.new("Edit action not allowed")
    end
    render_with_engine_fallback
  end

  # POST
  def create
    unless crud_actions.include?(:create)
      raise ActionController::RoutingError.new("Create action not allowed")
    end

    # allow setting @record, then calling super to complete the request
    if @record.nil?
      @record = model_class.new(record_params)
    end

    if @record.save
      respond_to do |format|
        format.html { redirect_to view_path(@record), notice: "#{model_class} was successfully created." }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @record.errors.full_messages } }
      end
    end
  end

  # PATCH/PUT
  def update
    unless crud_actions.include?(:update)
      raise ActionController::RoutingError.new("Update action not allowed")
    end

    if @record.update(record_params)
      respond_to do |format|
        format.html { redirect_to view_path(@record), notice: "#{model_class} was successfully updated." }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @record.errors.full_messages } }
      end
    end
  end

  # DELETE 
  def destroy
    unless crud_actions.include?(:destroy)
      raise ActionController::RoutingError.new("Destroy action not allowed")
    end

    @record.destroy
    redirect_to index_path(model_class), notice: "#{model_class} was successfully destroyed."
  end

  # PATCH /items/bulk
  def bulk
    unless crud_actions.include?(:update)
      raise ActionController::RoutingError.new("Bulk update action not allowed")
    end

    ids = params[:id]
    if ids.is_a?(String)
      ids = ids.split(',')
    end
    
    @records = records_scope.where(id: ids)

    ActiveRecord::Base.transaction do
      if @records.all? { |r| r.update(bulk_record_params) }
        respond_to do |format|
          format.html { redirect_back(fallback_location: index_path(model_class), notice: "#{@records.size} #{model_class} was successfully updated.") }
          format.json { render :index }
        end
      else
        error_messages = @records.map { |r| r.errors.full_messages }.flatten.uniq
        respond_to do |format|
          format.html do
            flash[:error] = "Failed to save: #{error_messages.join('; ')}"
            redirect_back(fallback_location: index_path(model_class))
          end
          
          format.json { render json: { errors: error_messages } }
        end
        raise ActiveRecord::Rollback.new("Validation failed")
      end
    end
  end
  
  def to_s
    self.class.to_s.sub(/Controller$/, '').underscore.gsub('_', ' ').titleize
  end

  def model_class
    from_var = self.class._crudable_model_class

    if from_var.nil?
      klass_name = self.class.to_s.sub(/Controller$/, '').singularize
      begin
        klass_name.constantize
      rescue NameError
        raise NameError.new("Cannot find model for controller #{self.class}. Assumed to be #{klass_name.inspect}. Set with crudable_controller_for ModelName in the controller.")
      end
    else
      from_var
    end
  end

  def crud_actions
    self.class._crudable_actions || [:index, :show, :create, :update, :destroy]
  end
  
  def pagination_limit
    if model_class.respond_to?(:crudable_config)
      model_class.crudable_config.pagination_limit
    else
      50 # default fallback
    end
  end
  
  def index_order
    # Use crudable config or fallback
    if model_class.respond_to?(:crudable_config)
      model_class.crudable_config.index_order
    else
      { id: :desc } # default fallback
    end
  end
  
  protected

  # Try host app's controller's views first.
  # If no override exists, then fall back to engine default template for the action
  def render_with_engine_fallback(action = action_name)
    # 1. First, try host app view in its usual location, IE, app/view/books/index.html.erb
    if lookup_context.exists?("#{controller_path}/#{action}", [], true)
      render "#{controller_path}/#{action}"
    else
      # 2. Otherwise, fall back to engine flat template path, IE, app/view/crudable/index.html.erb
      render template: "crudable/#{action}"
    end
  end
  
  def apply_search_params(scope)
    if params[:q] && model_class.respond_to?(:search_attributes)
      t = model_class.arel_table
      conds = nil
      model_class.search_attributes.each do |a|
        q = params[:q].to_s.strip
        next if q.blank?
        c = t[a].matches("%#{q}%")
        if conds.nil?
          conds = c
        else
          conds = conds.or(c)
        end
      end
      scope = scope.where(conds)
    elsif params[:q]
      flash[:error] = 'Search is not supported.'
    end
    scope
  end

  # Override if need to provide specific permissions or limiting scopes
  def records_scope
    model_class
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = records_scope.find(params[:id])
  end

  # Only allow a trusted parameter "safe list" through.
  def record_params
    tmp_record   = model_class.new # used to get input type
    klass_sym    = model_class.model_name.singular.underscore.to_sym
    simple_attrs = model_class.permitted_attributes
    array_attrs  = model_class.permitted_attributes.map do |a|
      a = a.to_s.gsub(/[^a-zA-Z0-9_]/, '') # scrub
      if tmp_record.respond_to?("#{a}_input_type") && tmp_record.send("#{a}_input_type") == :checkbox_multi
        [a, []]
      else
        nil
      end
    end.compact.to_h
    
    # Replicate this syntax .permit(:name, :description, friends: [])
    out = params.require(klass_sym).permit(*simple_attrs, **array_attrs)
    out
  end

  # same as record params, but removes where param value is is nil
  def bulk_record_params
    klass_sym = model_class.model_name.singular.underscore.to_sym
    attrs = model_class.permitted_attributes.reduce([]) do |acc, a|
      # NOTE, this does not support bulk updates to nested attributes for associated models
      if a.is_a?(Symbol) && params[klass_sym]
        if params[klass_sym][a].present?
          acc << a
        elsif a.to_s =~ /_id$/ # handle if :belongs_to_id is the attr but :belongs_to is the param
          aa = a.to_s.sub(/_id$/, '').to_sym
          acc << aa if params[klass_sym][aa].present?
        end
      end
      acc
    end
    params.require(klass_sym).permit(*attrs)
  end

  def record_not_found(error)
    if params[:format] == "json"
      msg = "Cannot find #{model_class.name} with ID #{params[:id].inspect}"
      render json: { error: msg }, status: :not_found
    else
      raise error
    end
  end
end
