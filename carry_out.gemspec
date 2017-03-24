# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carry_out/version'

Gem::Specification.new do |spec|
  spec.name          = "carry_out"
  spec.version       = CarryOut::VERSION
  spec.authors       = ["Ryan Fields"]
  spec.email         = ["ryan.fields@twoleftbeats.com"]

  spec.summary       = %q{Compose units of logic into an executable workflow.}
  spec.description   = <<-EOF
    CarryOut connects units of logic into workflows.  Each unit can extend
    the DSL with parameter methods.  Artifacts and errors are collected as
    the workflow executes and are returned in a result bundle upon completion.
  EOF

  spec.homepage      = "https://github.com/ryanfields/carry_out"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "coveralls"
end
