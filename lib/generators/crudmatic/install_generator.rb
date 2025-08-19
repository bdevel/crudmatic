require 'rails/generators'

module Crudmatic
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install Crudmatic by copying view templates and setup instructions"
      
      source_root File.expand_path('../../../../app/views/crudmatic', __FILE__)
      
      def copy_templates
        directory ".", "app/views/crudmatic"
      end
      
      def show_setup_instructions
        say
        say "=" * 60, :green
        say "Crudmatic Installation Complete!", :green
        say "=" * 60, :green
        say
        say "Templates have been copied to: app/views/crudmatic/", :blue
        say "You can now customize these templates to fit your application's needs.", :blue
        say
        say "Next steps:", :yellow
        say "1. Include CrudmaticHelper in your ApplicationController:", :white
        say "   include CrudmaticHelper", :cyan
        say
        say "2. Have your controllers inherit from CrudmaticController:", :white
        say "   class UsersController < CrudmaticController", :cyan
        say "     self.model_class = User", :cyan
        say "   end", :cyan
        say
        say "3. Include CrudmaticRecord in your models and configure:", :white
        say "   class User < ApplicationRecord", :cyan
        say "     include CrudmaticRecord", :cyan
        say
        say "     # Configure attributes for different contexts", :cyan
        say "     crudmatic :index_attributes,  [:name, :email, :created_at]", :cyan
        say "     crudmatic :edit_attributes,   [:name, :email, :active]", :cyan
        say "     crudmatic :search_attributes, [:name, :email]", :cyan
        say "     crudmatic :api_attributes,    [:id, :name, :email, :active]", :cyan
        say
        say "     # Add custom labels and input notes", :cyan
        say "     crudmatic :label, :active, \"Account Status\"", :cyan
        say "     crudmatic :input_note, :email, \"Must be a valid email address\"", :cyan
        say
        say "     # Configure dropdowns and radio buttons", :cyan
        say "     crudmatic :select_options, :status, %w{active inactive}", :cyan
        say "     crudmatic :radio, :role, %w{admin user guest}", :cyan
        say "   end", :cyan
        say
        say "For more information, check the documentation.", :green
        say
      end
    end
  end
end