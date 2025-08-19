module Crudable
  # CSS class configuration system for different frameworks
  class CssClasses
    def self.for_framework(framework = :bootstrap)
      case framework
      when :tailwind
        TailwindClasses.new
      else
        BootstrapClasses.new
      end
    end
  end
  
  # Bootstrap 5 CSS classes
  class BootstrapClasses
    # Layout & Structure
    def container_class; 'container-fluid'; end
    def row_class; 'row'; end
    def col_class; 'col'; end
    def card_class; 'card'; end
    def card_header_class; 'card-header'; end
    def card_body_class; 'card-body'; end
    
    # Tables
    def table_class; 'table table-striped table-bordered table-hover'; end
    def table_responsive_class; 'table-responsive'; end
    def table_sm_class; 'table-sm'; end
    
    # Buttons
    def btn_primary_class; 'btn btn-primary'; end
    def btn_secondary_class; 'btn btn-secondary'; end
    def btn_success_class; 'btn btn-success'; end
    def btn_danger_class; 'btn btn-danger'; end
    def btn_warning_class; 'btn btn-warning'; end
    def btn_info_class; 'btn btn-info'; end
    def btn_outline_primary_class; 'btn btn-outline-primary'; end
    def btn_outline_secondary_class; 'btn btn-outline-secondary'; end
    def btn_outline_success_class; 'btn btn-outline-success'; end
    def btn_outline_danger_class; 'btn btn-outline-danger'; end
    def btn_group_class; 'btn-group'; end
    def btn_xs_class; 'btn-sm'; end  # Bootstrap 5 doesn't have xs, use sm
    def btn_group_sm_class; 'btn-group btn-group-sm'; end
    
    # Alerts
    def alert_success_class; 'alert alert-success alert-dismissible fade show'; end
    def alert_danger_class; 'alert alert-danger alert-dismissible fade show'; end
    def alert_warning_class; 'alert alert-warning alert-dismissible fade show'; end
    def alert_info_class; 'alert alert-info alert-dismissible fade show'; end
    
    # Forms
    def form_group_class; 'row mb-3'; end
    def form_label_class; 'col-sm-2 col-form-label text-end fw-bold'; end
    def form_control_wrapper_class; 'col-sm-10'; end
    def form_text_class; 'form-text'; end
    def input_group_class; 'input-group'; end
    def input_group_sm_class; 'input-group input-group-sm'; end
    def input_group_text_class; 'input-group-text'; end
    def form_select_sm_class; 'form-select form-select-sm'; end
    
    # Navigation
    def navbar_class; 'navbar navbar-expand-lg bg-body-tertiary'; end
    def navbar_brand_class; 'navbar-brand'; end
    def navbar_nav_class; 'navbar-nav'; end
    def nav_item_class; 'nav-item'; end
    def nav_link_class; 'nav-link'; end
    def navbar_text_class; 'navbar-text'; end
    
    # Utilities
    def text_center_class; 'text-center'; end
    def text_end_class; 'text-end'; end
    def text_start_class; 'text-start'; end
    def text_muted_class; 'text-muted'; end
    def nowrap_class; 'text-nowrap'; end
    def d_flex_class; 'd-flex'; end
    def gap_2_class; 'gap-2'; end
    def mb_3_class; 'mb-3'; end
    def offset_sm_2_class; 'offset-sm-2'; end
    
    # Pagination
    def pagination_wrapper_class; 'd-flex justify-content-between align-items-center'; end
    def pagination_class; 'pagination'; end
    def page_item_class; 'page-item'; end
    def page_link_class; 'page-link'; end
    def page_item_active_class; 'page-item active'; end
    def page_item_disabled_class; 'page-item disabled'; end
  end
  
  # Tailwind CSS classes
  class TailwindClasses
    # Layout & Structure
    def container_class; 'container mx-auto px-4'; end
    def row_class; 'flex flex-wrap'; end
    def col_class; 'flex-1'; end
    def card_class; 'bg-white shadow-lg rounded-lg'; end
    def card_header_class; 'bg-gray-50 px-6 py-3 border-b border-gray-200'; end
    def card_body_class; 'p-6'; end
    
    # Tables
    def table_class; 'min-w-full divide-y divide-gray-200'; end
    def table_responsive_class; 'overflow-x-auto'; end
    def table_sm_class; 'text-sm'; end
    
    # Buttons
    def btn_primary_class; 'bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_secondary_class; 'bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_success_class; 'bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_danger_class; 'bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_warning_class; 'bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_info_class; 'bg-cyan-500 hover:bg-cyan-700 text-white font-bold py-2 px-4 rounded'; end
    def btn_outline_primary_class; 'border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white font-bold py-2 px-4 rounded'; end
    def btn_outline_secondary_class; 'border border-gray-500 text-gray-500 hover:bg-gray-500 hover:text-white font-bold py-2 px-4 rounded'; end
    def btn_outline_success_class; 'border border-green-500 text-green-500 hover:bg-green-500 hover:text-white font-bold py-2 px-4 rounded'; end
    def btn_outline_danger_class; 'border border-red-500 text-red-500 hover:bg-red-500 hover:text-white font-bold py-2 px-4 rounded'; end
    def btn_group_class; 'inline-flex'; end
    def btn_xs_class; 'text-xs py-1 px-2'; end
    
    # Alerts
    def alert_success_class; 'bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative'; end
    def alert_danger_class; 'bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative'; end
    def alert_warning_class; 'bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded relative'; end
    def alert_info_class; 'bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded relative'; end
    
    # Forms
    def form_group_class; 'mb-4'; end
    def form_label_class; 'block text-sm font-medium text-gray-700 mb-1 text-right'; end
    def form_control_wrapper_class; 'flex-1'; end
    def form_text_class; 'text-sm text-gray-500 mt-1'; end
    def input_group_class; 'flex'; end
    def input_group_sm_class; 'flex text-sm'; end
    def input_group_text_class; 'inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md'; end
    def form_select_sm_class; 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-r-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2'; end
    
    # Navigation
    def navbar_class; 'bg-white shadow-lg'; end
    def navbar_brand_class; 'text-xl font-bold text-gray-800'; end
    def navbar_nav_class; 'flex space-x-4'; end
    def nav_item_class; ''; end
    def nav_link_class; 'text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium'; end
    def navbar_text_class; 'text-gray-600 text-sm'; end
    
    # Utilities
    def text_center_class; 'text-center'; end
    def text_end_class; 'text-right'; end
    def text_start_class; 'text-left'; end
    def text_muted_class; 'text-gray-500'; end
    def nowrap_class; 'whitespace-nowrap'; end
    def d_flex_class; 'flex'; end
    def gap_2_class; 'gap-2'; end
    def mb_3_class; 'mb-3'; end
    def offset_sm_2_class; 'sm:ml-16'; end  # Approximate offset
    
    # Pagination
    def pagination_wrapper_class; 'flex justify-between items-center'; end
    def pagination_class; 'flex space-x-1'; end
    def page_item_class; ''; end
    def page_link_class; 'px-3 py-2 text-sm leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700'; end
    def page_item_active_class; 'z-10 px-3 py-2 text-sm leading-tight text-blue-600 bg-blue-50 border border-blue-300'; end
    def page_item_disabled_class; 'px-3 py-2 text-sm leading-tight text-gray-300 bg-white border border-gray-300 cursor-not-allowed'; end
  end
end