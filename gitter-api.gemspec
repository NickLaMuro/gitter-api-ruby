lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gitter/api/version"

Gem::Specification.new do |spec|
  spec.name          = "gitter-api"
  spec.version       = Gitter::API::VERSION
  spec.authors       = ["Nick LaMuro"]
  spec.email         = ["nicklamuro@gmail.com"]

  spec.summary       = "An(other) Ruby API client for Gitter"
  spec.description   = <<-DESC.gsub(/^ {4}/, '')
    A ruby client for the gitter (https://gitter.im) API.

    Includes an `ActiveRecord`-like interface with models that are parsed from
    the responses, as well as a lower level request/json-response interface.
  DESC
  spec.homepage      = "https://github.com/NickLaMuro/gitter-api-ruby"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w[README.md LICENSE.txt]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
