require 'rails/generators'

module Crudable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install Crudable by copying view templates and setup instructions"
      
      source_root File.expand_path('../../../../app/views/crudable', __FILE__)
      
      def copy_templates
        directory ".", "app/views/crudable"
      end
      
      def show_setup_instructions
        say
        say "=" * 60, :green
        say "Crudable Installation Complete!", :green
        say "=" * 60, :green
        say
        say "Templates have been copied to: app/views/crudable/", :blue
        say "You can now customize these templates to fit your application's needs.", :blue
        say
        say "Next steps:", :yellow
        say "1. Include CrudableHelper in your ApplicationController:", :white
        say "   include CrudableHelper", :cyan
        say
        say "2. Have your controllers inherit from CrudableController:", :white
        say "   class UsersController < CrudableController", :cyan
        say "     self.model_class = User", :cyan
        say "   end", :cyan
        say
        say "3. Include CrudableRecord in your models and configure:", :white
        say "   class User < ApplicationRecord", :cyan
        say "     include CrudableRecord", :cyan
        say
        say "     # Configure attributes for different contexts", :cyan
        say "     crudable :index_attributes,  [:name, :email, :created_at]", :cyan
        say "     crudable :edit_attributes,   [:name, :email, :active]", :cyan
        say "     crudable :search_attributes, [:name, :email]", :cyan
        say "     crudable :api_attributes,    [:id, :name, :email, :active]", :cyan
        say
        say "     # Add custom labels and input notes", :cyan
        say "     crudable :label, :active, \"Account Status\"", :cyan
        say "     crudable :input_note, :email, \"Must be a valid email address\"", :cyan
        say
        say "     # Configure dropdowns and radio buttons", :cyan
        say "     crudable :select_options, :status, %w{active inactive}", :cyan
        say "     crudable :radio, :role, %w{admin user guest}", :cyan
        say "   end", :cyan
        say
        say "For more information, check the documentation.", :green
        say
      end
    end
  end
end