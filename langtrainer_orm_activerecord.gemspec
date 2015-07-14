$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "langtrainer_orm_activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "langtrainer_orm_activerecord"
  s.version     = LangtrainerOrmActiverecord::VERSION
  s.authors     = ["Yury Kotov"]
  s.email       = ["bairkan@gmail.com"]
  s.homepage    = "https:/github.com/langtrainer/langtrainer_orm_activerecord"
  s.summary     = "Data layer for langtrainer API"
  s.description = "Data layer shared between langtrainer API and backoffice"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "activerecord", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "rails", "~> 4.2.0"
end
