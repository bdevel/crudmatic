require 'rails/generators'

module Crudmatic
  module Generators
    class TemplatesGenerator < Rails::Generators::Base
      desc "Copy Crudmatic view templates to the host application for customization"
      
      source_root File.expand_path('../../../../app/views/crudmatic', __FILE__)
      
      def copy_templates
        directory ".", "app/views/crudmatic"
      end
      
      def show_readme
        say
        say "Crudmatic templates have been copied to app/views/crudmatic/", :green
        say "You can now customize these templates to fit your application's needs.", :green
        say
      end
    end
  end
end