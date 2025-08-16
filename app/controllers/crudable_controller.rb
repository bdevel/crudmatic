class CrudableController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  include CrudableHelper

  append_view_path File.join(Crudable::Engine.root, 'app', 'views', 'crudable')
  
  class << self
    # allow accessing MyItemsController.crud_actions 
    attr_accessor :model_class
    attr_accessor :search_attributes
    attr_accessor :crud_actions

    # set defaults
    def inherited(child)
      super(child)
      child.crud_actions = [:show, :create, :edit, :delete, :preview]
    end
  end
  
  before_action :set_record, only: [:show, :edit, :update, :destroy]

  # GET
  def index
    @records = records_scope
    
    # Apply ordering using the new config system
    @records = @records.order(index_order)

    @records = apply_search_params(@records)
    
    # Apply pagination using offset
    @total_count = @records.count
    @offset = params[:offset].to_i
    @limit = pagination_limit
    @records = @records.offset(@offset).limit(@limit)
    
    # Calculate pagination info
    @current_page = (@offset / @limit) + 1
    @total_pages = (@total_count.to_f / @limit).ceil
    @has_previous = @offset > 0
    @has_next = @offset + @limit < @total_count
    @previous_offset = [@offset - @limit, 0].max
    @next_offset = @offset + @limit
    
  end

  # def search
  #   @records = model_class.page(params[:page]).order(:updated_at => :desc)
    
  #   render :index
  # end

  def show
  end

  def new
    @record = model_class.new
  end

  def edit

  end

  # POST
  def create
    # allow setting @record, then calling super to complete the request
    if @record.nil?
      @record = model_class.new(record_params)
    end

    if @record.save
      respond_to do |format|
        format.html {redirect_to view_path(@record), notice: "#{model_class} was successfully created."}
        format.json {render :show}
      end
    else
      respond_to do |format|
        format.html {render :new}
        format.json {render json: {errors: @record.errors.full_messages}}
      end
    end
  end

  # PATCH/PUT
  def update
    if @record.update(record_params)
      respond_to do |format|
        format.html {redirect_to view_path(@record), notice: "#{model_class} was successfully updated."}
        format.json {render :show}
      end
    else
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: {errors: @record.errors.full_messages}}
      end
    end
  end

  # DELETE 
  def destroy
    @record.destroy
    redirect_to index_path(model_class), notice: "#{model_class} was successfully destroyed."
  end

  # PATCH /items/bulk
  def bulk
    ids = params[:id]
    if ids.is_a?(String)
      ids = ids.split(',')
    end
    
    @records = records_scope.where(id: ids)

    ActiveRecord::Base.transaction do
      if @records.all? { |r| r.update(bulk_record_params) }
        respond_to do |format|
          format.html {redirect_back(fallback_location: index_path(model_class), notice: "#{@records.size} #{model_class} was successfully updated.")}
          format.json {render :index}
        end
      else
        error_messages = @records.map{|r| r.errors.full_messages}.flatten.uniq
        respond_to do |format|
          format.html do
            flash[:error] = "Failed to save: #{error_messages.join('; ')}"
            redirect_back(fallback_location: index_path(model_class))
          end
          
          format.json {render json: {errors: error_messages}}
        end
        raise ActiveRecord::Rollback.new("Validation failed")
      end
    end

  end
  
  def to_s
    self.class.to_s.sub(/Controller$/, '').underscore.gsub('_', ' ').titleize
  end

  def model_class
    from_var = self.class.instance_variable_get(:@model_class)

    if from_var.nil?
      klass_name = self.class.to_s.sub(/Controller$/, '').singularize
      begin
        klass_name.constantize
      rescue NameError
        raise NameError.new("Cannot find model for controler #{self.class}. Assumed to be #{klass_name.inspect}. Set with self.model_class = ModelName in the controller. ")
      end
    else
      from_var
    end
  end

  def crud_actions
    # show should be implied, it's not really an action anyway
    list = self.class.instance_variable_get(:@crud_actions)
    list || [:show, :create, :edit, :delete]
  end
  
  def pagination_limit
    if model_class.respond_to?(:crudable_config)
      model_class.crudable_config.pagination_limit
    else
      50 # default fallback
    end
  end
  
  def index_order
    # Allow override via ?sort_by parameter
    # if params[:sort_by].present?
    #   column = params[:sort_by].to_sym
    #   direction = params[:sort_direction]&.to_sym || :asc
      
    #   # Validate that the column exists to prevent SQL injection
    #   valid_columns = model_class.column_names.map(&:to_sym)
    #   if valid_columns.include?(column)
    #     return { column => direction }
    #   end
    # end
    
    # Use crudable config or fallback
    if model_class.respond_to?(:crudable_config)
      model_class.crudable_config.index_order
    else
      { id: :desc } # default fallback
    end
  end
  
  protected

  def apply_search_params(scope)
    if params[:q] && model_class.respond_to?(:search_attributes)
      t = model_class.arel_table
      conds = nil
      model_class.search_attributes.each do |a|
        #a = a.to_s.gsub(/[^a-zA-Z0-9_-]/, '')
        q = params[:q].to_s.strip
        next if q.blank?
        c = t[a].matches("%#{q}%")
        if conds.nil?
          conds = c
        else
          conds = conds.or(c)
        end
      end
      scope = scope.where(conds) #"\"#{model_class.table_name}\".\"#{a}\" LIKE ?", "%#{q}%")
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
        #[a, @record.send("#{a}_select_options")] # doesn't seem to reject items no in the array as expected, just
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
    attrs = model_class.permitted_attributes.reduce([]) do |acc,a|
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
    if params[:format]== "json"
      msg = "Cannot find #{model_class.name} with ID #{params[:id].inspect}"
      render :json => {:error => msg}, :status => :not_found
    else
      raise error
    end
  end 
end
