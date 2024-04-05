$LOAD_PATH.push File.expand_path('lib', __dir__)

version = File.read(File.expand_path("../CODALIO_VERSION", __dir__)).strip

Gem::Specification.new do |spec|
  spec.name        = 'codalio_ai'
  spec.version     = version
  spec.authors     = ['JP Rosevear']
  spec.email       = ['jprosevear@nubinary.com']
  spec.homepage    = ''
  spec.summary     = ''
  spec.description = ''
  spec.license     = "MIT"

  spec.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md', 'LICENSE']

  spec.add_dependency "rails", "~> 7.0.0", ">= 7.0.0"
  spec.add_dependency "rhino_project_core"
  spec.add_dependency "rake", "~> 13.1"
end
