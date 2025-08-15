require 'rails/generators'

module Crudable
  module Generators
    class TemplatesGenerator < Rails::Generators::Base
      desc "Copy Crudable view templates to the host application for customization"
      
      source_root File.expand_path('../../../../app/views/crudable', __FILE__)
      
      def copy_templates
        directory ".", "app/views/crudable"
      end
      
      def show_readme
        say
        say "Crudable templates have been copied to app/views/crudable/", :green
        say "You can now customize these templates to fit your application's needs.", :green
        say
      end
    end
  end
end