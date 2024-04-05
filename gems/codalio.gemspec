# frozen_string_literal: true

version = File.read(File.expand_path("CODALIO_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "codalio"
  s.version     = version
  s.summary     = ""
  s.description = ""

  s.required_ruby_version     = ">= 3.1.0"
  s.required_rubygems_version = ">= 1.8.11"

  s.license = "MIT"

  s.author   = ""
  s.email    = ""
  s.homepage = "https://codalio.com"

  s.files = ["README.md", "LICENSE"]

  s.metadata = {
  }

  s.add_dependency "codalio_ai", version
  s.add_dependency "bundler", ">= 1.15.0"
end
