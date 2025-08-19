module CrudableHelper

  def page_title
    if @page_title.present?
      return @page_title
    elsif controller.respond_to?(:model_class)
      if params[:action] == "index"
        controller.model_class.to_s.pluralize
      elsif params[:action] == "new"
        "New " + controller.model_class.to_s
        
      elsif params[:action] == "edit"
        "Edit #{controller.model_class.to_s}: " + @record.to_s
        
      elsif params[:action] == "show"
        controller.model_class.to_s.singularize + ' ' + @record.to_s
      else
        controller.to_s.pluralize
      end
    elsif @record.present?
      name = ''
      name = @record.title if name.blank? && @record.respond_to?(:title)
      name = @record.name if name.blank? && @record.respond_to?(:name)
      controller.class.to_s.titleize.sub(/ Controller$/, '')  + ' ' + name
    else
      controller.class.to_s.titleize.sub(/ Controller$/, '')
    end
    
  end

  def record_type_plural(record)
    record.class.name.underscore.pluralize
  end
  
  def normalize_attr_name(record, attr)
    
    if attr.to_s == 'itself'
      attr = record.class.name.underscore
    end
    
    if attr.is_a?(Hash)
      attr = attr.keys.first
    end

    # Not sure what this handles..
    if attr.to_s =~ /_ids$/ && !attr_is_relation?(record, attr)
      attr = attr.to_s.sub(/_ids$/, '').pluralize
    end

    # Handles belongs to parent_id
    if attr.to_s =~ /_id$/ && attr_is_relation?(record, attr)
      attr = attr.to_s.sub(/_id$/, '')
    end
    attr
  end
  
  # item is instance of a model
  def model_attr_label(record, attr)
    if record.is_a?(Hash)
      return titleize_attr(attr.to_s)
    end
    
    # Check if there's a custom label defined in crudable config
    if record.respond_to?(:crudable_config)
      custom_label = record.crudable_config.label_for(attr)
      return custom_label if custom_label
    end
    
    # attr = attr.to_s.sub(/_ids$/){|s, n| n.pluralize rescue s }
    # attr = attr.to_s.sub(/_id$/){|s, n| n }
    attr = normalize_attr_name(record, attr)
    model_name = record.class.name.underscore
    t = I18n.t("model.#{model_name}.#{attr.to_s}")

    if t.downcase.include?('translation missing')
      titleize_attr(attr)
    else
      t
    end
  end

  # Fallback if translation is not available.
  def titleize_attr(attr)
    acronyms = %w{url ip asn sim iccid imei adb id api hms gtr vk dpc dps tld csn tv http socks socks5} # Will UPCASE these
    t = attr.to_s.gsub('_', ' ').titleize #.gsub(/\bId\b/, "ID")

    acronyms.each do |a|
      t = t.sub(/\b#{a.titleize}\b/, a.upcase)
    end
    t
  end

  def attr_is_relation?(item, attr)
    model = item.class
    if !model.respond_to?(:reflect_on_all_associations)
      return false
    end
    rel_attrs = []
    rel_attrs += model.reflect_on_all_associations(:belongs_to).map {|a| a.name}
    rel_attrs += model.reflect_on_all_associations(:has_many).collect {|a| a.name}
    rel_attrs += model.reflect_on_all_associations(:has_and_belongs_to_many).collect {|a| a.name}
    rel_attrs.map(&:to_s).include?(attr.to_s.sub(/_id$/, ''))
  end

  # def crud_attribute_list(&block)
  #   content_tag(:div, class: 'form-horizontal') do
  #     concat block.call
  #   end
  #   #     .form-horizontal
  #   # - record.class.show_attributes.each do |f|
  #   #                                          .form-group
  #   #                                                  .col.col-sm-2.control-label
  #   #   %label= model_attr_label(record, f)
  #   #             .col.col-sm-10.form-control-static
  #   #   = formatted_value(record, f, :show)
  #   #   &nbsp;

  # end

  # def crud_attribute_item(label, value)
  #   content_tag(:div, class: 'form-group') do
  #     capture  do
  #       concat content_tag(:div, class: %w(col col-sm-2 control-label)) do
  #         content_tag(:label, label).html_safe
  #       end.html_safe
  #       concat value
  #     end
  #   end.html_safe
  #   #     .form-horizontal
  #                   # - record.class.show_attributes.each do |f|
  #   #                                          .form-group
  #   #                                                  .col.col-sm-2.control-label
  #   #   %label= model_attr_label(record, f)
  #   #             .col.col-sm-10.form-control-static
  #   #   = formatted_value(record, f, :show)
  #   #   &nbsp;

  # end

  def crud_edit_attr(form, attr, settings=nil)
    settings = {} if settings.nil?
    #settings = {include_blank: false} if settings.nil?
    record = form.object
    model = record.class

    begin
      return render(partial: "#{model.model_name.plural}/#{attr}_input", locals: {f: form, record: record, attribute: attr})
    rescue ActionView::MissingTemplate => e
      # Ignore, do default
    end
    
    # reflection api http://api.rubyonrails.org/classes/ActiveRecord/Reflection/ClassMethods.html
    belongs_tos = model.reflect_on_all_associations(:belongs_to).map {|a| a.name}    
    has_manys = model.reflect_on_all_associations(:has_many).collect {|a| a.name}
    has_manys += model.reflect_on_all_associations(:has_and_belongs_to_many).collect {|a| a.name}

    column = model.columns.select {|c| c.name.to_s == attr.to_s}.first

    # Use crudable config for type detection if available
    if record.respond_to?(:crudable_config)
      type = record.crudable_config.input_type_for(attr)
      opts = record.crudable_config.select_options_for(attr, record)
    elsif record.respond_to?("#{attr}_input_type")
      type = record.send("#{attr}_input_type") #allow override, useful for JSON db type
      opts = record.send(attr.to_s + "_select_options") rescue nil
    elsif belongs_tos.include?(attr.to_s.sub(/_id$/, '').to_sym)
      type = :belongs_to
      opts = nil
    elsif has_manys.include?(attr.to_s.sub(/_ids$/, '').pluralize.to_sym)
      type = :has_many
      opts = nil
    elsif column
      type = column.type
      opts = record.send(attr.to_s + "_select_options") rescue nil
    else
      raise "unknown type for attribute #{attr.inspect}"
    end


    
    if type == :radio && opts
      content_tag(:div, class: 'radio-group') do
        opts.map do |option|
          content_tag(:div, class: 'radio') do
            content_tag(:label) do
              form.radio_button(attr, option, class: 'form-control-radio') + " #{option}"
            end
          end
        end.join.html_safe
      end
      
    elsif type == :select && opts
      val = record_attr_value(record, attr)
      if settings.key?(:include_blank)
        include_blank = settings[:include_blank]
      elsif val.blank?
        # ie, a new record, then don't select the first item in the dropdown by default..
        include_blank = true
      else
        include_blank = !model.validators_on(attr).map(&:kind).include?(:presence) rescue false
      end
      
      form.collection_select(attr, opts, :to_s, :to_s, {include_blank: include_blank}, {class: 'form-control'})
      
    elsif type == :string && opts
      val = record_attr_value(record, attr)
      if settings.key?(:include_blank)
        include_blank = settings[:include_blank]
      elsif val.blank?
        # ie, a new record, then don't select the first item in the dropdown by default..
        include_blank = true
      else
        include_blank = !model.validators_on(attr).map(&:kind).include?(:presence) rescue false
      end
      
      form.collection_select(attr, opts, :to_s, :to_s, {include_blank: include_blank}, {class: 'form-control'})
      
    elsif type == :string || type == :json
      form.text_field(attr, :class => 'form-control')
      
    elsif type == :text
      lines = formatted_value(record, attr).to_s.split("\n").size
      lines = [20,lines].min # max of 20 lines
      form.text_area(attr, :class => 'form-control', :rows => [lines, 3].max)
      
    elsif type == :boolean
      form.check_box(attr, :class => 'form-control')
      
    elsif type == :integer
      form.number_field(attr, :class => 'form-control')
      
    elsif type == :float || type == :decimal
      form.number_field(attr, :class => 'form-control', :step => 0.01)
      
    elsif type == :date
      form.date_field(attr, :class => 'form-control')
      
    elsif type == :datetime
      form.datetime_field(attr, :class => 'form-control')
      
    elsif type == :belongs_to
      # needs to match the association name with the column name, not so great if configured differently
      default_include_blank = model.reflect_on_all_associations(:belongs_to).select{|a|a.name.to_s == attr.to_s.sub('_id', '')}.first.options[:optional] rescue true

      include_blank = default_include_blank
      include_blank = settings[:include_blank] if settings.key?(:include_blank)
      
      opts = record.select_options_for_belongs_to(attr.to_s.sub(/_id$/, ''))
      bt_attr = attr
      bt_attr = "#{attr}_id".to_sym unless attr.to_s =~ /_id$/
      form.collection_select(bt_attr, opts, :id, :to_s, { prompt: '', include_blank: include_blank }, { class: 'form-control' })

    elsif type == :checkbox_multi
      opts = record.send("#{attr}_select_options")
      field_name = "#{form.object_name}[#{attr.to_s}][]"
      render partial: 'crudable/check_box_select', locals: {options: opts, field_name: field_name, selected: record.send(attr).to_a}
      
    elsif type == :has_many
      # Adding _ids to the name for checkbox select. Permitted params must have attr_ids allowed
      ids_name = "#{attr.to_s.singularize}_ids"
      opts = record.select_options_for_has_many(attr.to_s.sub(/_ids$/, ''))
      # don't think we need to handle settings[:include_blank] because checkboxes that should be implied
      field_name = "#{form.object_name}[#{ids_name}][]"
      render partial: 'crudable/check_box_select', locals: {options: opts, field_name: field_name, selected: record.send(ids_name)}
      #kennel[handler_ids][]"
      # concat(
      # hidden_field_tag(field_name, nil)
      # content_tag(:ul, class: 'list-unstyled') do
      #   opts.collect do |o|
      #     concat content_tag(:li) do
      #       o.to_s
      #     end
      #     #<label><%= check_box_tag("kennel[handler_ids][]", id, id.in?(@kennel.handlers.collect(&:id))) %> <%= handler.name %></label>
      #     # concat content_tag(:li) do
      #     #   concat content_tag(:label) do
      #     #     concat o.to_s,
      #     #            check_box_tag(field_name, o.id )
      #     #   end
      #     # end
      #   end
      # end
      # )
      #form.collection_check_boxes(attr, opts, :id, :to_s, class: 'form-control')

    else
      raise "unknown form input type for '#{type}'"
    end
    
  end

  def record_attr_value(record, attr)
    if attr_is_relation?(record, attr)
      begin
        return record.send attr.to_s.sub(/_id$/, '')
      rescue
        return record.send attr.to_s
      end
    elsif attr.is_a?(Hash)
      # Support supplying a hash as an attribute which is used to configure
      # how to display has many listings
      key = attr.keys.first
           
      return record.send(key)
      
    elsif record.is_a?(Hash)
      if attr.is_a?(Array)
        return record.with_indifferent_access.dig(*attr)
      else
        return record[attr]
      end
    else
      return record.send(attr)
    end
  end
  
  def formatted_value(record, attr, context=nil)
    
    # declare these incase attr is a relationship
    listing_attributes = nil
    listing_actions    = false

    column_type = nil
    if record.class.respond_to?(:columns)
      column = record.class.columns.select {|c| c.name.to_s == attr.to_s}.first
      column_type = column.type if column
    end
    
    val = record_attr_value(record, attr)

    if attr.is_a?(Hash)
      # Ex, attr may be {:latest_metrics => [:attr, :attr_specific, :value, :created_at]}
      # Ex, attr may be {:latest_metrics => {attributes: [:attr, :attr_specific, :value, :created_at]}, actions: [:show]}
      attr_name = attr.keys.first
      if attr[attr_name].is_a?(Hash) && attr[attr_name][:attributes]
        listing_attributes = attr[attr_name][:attributes]
        listing_actions    = attr[attr_name][:actions]
        
      elsif attr[attr.keys.first].is_a?(Array)
        listing_attributes = attr[attr_name]
      else
        listing_attributes = nil # not sure what it would be..
      end

    end
    
    if val.is_a?(Date)
      val.strftime("%Y-%m-%d")
    elsif val.respond_to?(:strftime) && val.respond_to?(:utc)
      #I18n.localize v
      val.strftime("%Y-%m-%d %H:%M:%S %z")
    elsif val.class.ancestors.include?(Enumerable)
      if val.is_a?(Array) && val.first.is_a?(Hash)
        # do same as elsif val.is_a?(Array)
        if val.first.respond_to?(:keys) && listing_attributes.blank?
          listing_attributes = val.first.keys
        end
        return render :partial => 'crudable/listing', locals: {records: val, 
          actions: listing_actions,
          attributes: listing_attributes}
        
      elsif context == :listing || (val.is_a?(Array) && !val.first.is_a?(Hash) && !val.first.class.respond_to?(:index_attributes))
        # is a simple type. TODO, better way to check than this condition?
        content_tag(:ul, :class => 'list-unindented') do
          val.collect do |v|
            concat content_tag(:li, formatted_value(v, :itself, context))
          end
        end
        
      elsif val.is_a?(Array)
        if val.first.respond_to?(:keys) && listing_attributes.blank?
          listing_attributes = val.first.keys
        end
        
        return render :partial => 'crudable/listing', locals: {records: val, 
          actions: listing_actions,
          attributes: listing_attributes}
        
      elsif  val.is_a?(Hash)
        return render :partial => 'crudable/hashmap_show', locals: {record: val, 
          #actions: listing_actions,
          attributes: val.keys}
      else
        return render :partial => 'crudable/listing', locals: {records: val, 
          actions: listing_actions,
          attributes: listing_attributes}
      end
      
    elsif val.respond_to?(:model_name)
      # Check if we have custom attributes to display for this single object
      if listing_attributes && listing_attributes.any?
        return render :partial => 'crudable/show', locals: {record: val, 
          attrs: listing_attributes}
      else
        path = view_path(val)
        
        if path
          link_to val.to_s, view_path(val)
        else
          val.to_s
        end
      end

      
    elsif column_type == :boolean || [true,false].include?(val)
      if attr == :is_web_enabled
        #raise val.inspect
      end
      
      if val == true
        return content_tag(:span, "", :class => "glyphicon glyphicon-ok", style: "color: green").html_safe
      elsif val.nil?
        return content_tag(:span, "", :class => "glyphicon glyphicon-minus", style: "color: #999", title: 'nil').html_safe
      elsif val == false
        return content_tag(:span, "", :class => "glyphicon glyphicon-remove", style: "color: red").html_safe
      else
        return val.inspect
      end
      
    elsif val.is_a?(Numeric)
      number_with_delimiter(val)
      
    elsif val.is_a?(String) && val.include?("\n")
      # simple_format allows some html tags which not preferred.
      val = h(val) unless val.html_safe?
      simple_format(val)
      # instead, just make new lines as break tags, as in preformated text
      # content_tag(:p, style: "white-space: pre;") do
      #   val
      # end
    elsif val.is_a?(String) && val =~ /^https?\:/ && !val.include?('@')  && !val.include?('<') # is a URL, but doesn't have a username specified
      # add a external link button, with text URL, instead of making entire link clickable.
      content_tag(:span) do
        text = link_to(content_tag(:span, "", :class => "glyphicon glyphicon glyphicon-share").html_safe, val.to_s, target: "w#{rand}", rel: 'noreferrer nofollow')
        text += ' ' + val.to_s
        text
      end
    else
      val
    end
    
  end


  def record_as_json(record)
    json = {
      id: record.id,
      type: record_type_plural(record),
      links: {self: api_full_url(record)},
      attributes: {}
    }
    
    record.class.api_attributes.each do |attr|
      val       = nil
      attr_name = normalize_attr_name(record, (attr.is_a?(Hash) ? attr.keys.first : attr))
      
      # Set the val variable
      if attr_is_relation?(record, attr)
        begin
          val = record.send attr.to_s.sub(/_id$/, '')
        rescue
          val = record.send attr.to_s
        end
        
      elsif attr.is_a?(Hash)
        # Support supplying a hash as an attribute which is used to configure
        # how to display has many listings
        key = attr.keys.first
        conf = attr[key]
        
        if conf.is_a?(Hash)
          listing_attributes = conf[:attributes]
          listing_actions    = conf[:actions]
        else
          listing_attributes = conf
        end
        
        val = record.send(key)
      else
        val = record.send(attr)
      end

      # Now that we know what val is, set it properly
      if val.is_a?(Array) || val.is_a?(Hash)
        json[:attributes][attr_name] = val
        
      elsif val.class.ancestors.include?(Enumerable)
        # has many relationship
        json[:relationships] ||= {}
        json[:relationships][attr_name] = {
          links: {}, # TODO: don't really do links for has many.. "http://example.com/articles/1/comments"
          data: val.map do |v|
            {id: v.id,
              type: record_type_plural(v),
              links: {:self => api_full_url(v) }
            }
          end
        }
        #json[:included] ||= []
        
      elsif val.respond_to?(:model_name)
        # single relationship
        json[:relationships] ||= {}
        json[:relationships][attr_name] = {
          # No point in adding this because adding self link to item.
          #links: {related: api_full_url(val)},
          data: {id: val.id, type: record_type_plural(val), links: {:self => api_full_url(val) }}
        }
        
      elsif val.respond_to?(:strftime)
        json[:attributes][attr_name] = val.as_json
      else
        json[:attributes][attr_name] = val
      end
      
    end
    json
  end
  
  def index_path(klass)
    klass = controller.model_class unless klass.respond_to?(:model_name)
    send("#{klass.model_name.plural.underscore}_path")
  end

  def new_path(klass)
    klass = controller.model_class unless klass.respond_to?(:model_name)
    send("new_#{klass.model_name.singular.underscore}_path") rescue nil
  end
  
  def view_path(record)
    if record.respond_to?(:new_record?) && record.new_record?
      nil # use new_or_edit
    elsif record.respond_to?(:model_name)
      send("#{record.model_name.singular.underscore}_path", record) rescue nil
    else
      name = record.class.to_s.downcase.gsub(' ', '_')
      send("#{name}_path", record) rescue nil
    end
  end
  
  def edit_path(record)
    if record.respond_to?(:new_record?) && record.new_record?
      nil # use new_or_edit
    else
      send("edit_#{record.model_name.singular.underscore}_path", record) rescue nil
    end
  end

  def bulk_path(klass)
    send("bulk_#{klass.model_name.plural.underscore}_path")
  end
  
  def new_or_edit_path(record)
    if record.respond_to?(:new_record?) && record.new_record?
      send("new_#{record.record_name.singular}_path", record) rescue nil
    else
      send("edit_#{record.model_name.singular.underscore}_path", record) rescue nil
    end
  end

  def api_full_url(record)
    #request.env["rack.url_scheme"] # doesn't work with nginx, always http
    scheme = Rails.env.production? ? 'https' : 'http'
    link_host = scheme + "://" + request.env["HTTP_HOST"]
    
    path = view_path(record)
    return nil if path.nil? # might happen if can't determine route for object
    link_host + path + '.json'
  end

  def can_search?(record)
    !controller.model_class.search_attributes.empty?
  end
  
  def input_note_for(record, attr)
    if record.respond_to?(:crudable_config)
      record.crudable_config.input_note_for(attr)
    end
  end
  
  def active_nav_item_class(url)
    if request.path == url
      'active'
    else
      ''
    end
  end
  
  def action_ok?(ok_actions, action)
    # nil means allow all. False means no actions
    return false if ok_actions == false
    ok_actions.nil? || (ok_actions == true) || ok_actions.include?(action)
  end

  private
  
end
