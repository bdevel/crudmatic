require_relative "lib/crudmatic/version"

Gem::Specification.new do |spec|
  spec.name        = "crudmatic"
  spec.version     = Crudmatic::VERSION
  spec.authors     = [ "bdevel" ]
  spec.email       = [ "github@polar-concepts.com" ]
  spec.homepage    = "https://github.com/bdevel/crudmatic"
  spec.summary     = "A web interface for CRUD operations for Ruby on Rails ActiveRecords."
  spec.description = "Automatically generates the index, show, and edit pages. Allows for customization."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.2.1"
end
