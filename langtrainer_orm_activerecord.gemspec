$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "langtrainer_orm_activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "langtrainer_orm_activerecord"
  s.version     = LangtrainerOrmActiverecord::VERSION
  s.authors     = ["Yury Kotov"]
  s.email       = ["bairkan@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of LangtrainerOrmActiverecord."
  s.description = "TODO: Description of LangtrainerOrmActiverecord."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "cranky"
end
