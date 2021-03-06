# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rtasklib/version'

Gem::Specification.new do |spec|
  spec.name          = "rtasklib"
  spec.version       = Rtasklib::VERSION
  spec.authors       = ["Will Paul"]
  spec.email         = ["whp3652@rit.edu"]

  spec.summary       = %q{A Ruby wrapper around the TaskWarrior CLI}
  spec.description   = %q{A Ruby wrapper around the TaskWarrior CLI. Requires a TaskWarrior install version 2.4.0 of greater.}
  spec.homepage      = "http://github.com/dropofwill/rtasklib"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0'
  spec.requirements << 'taskwarrior, >=2.4.0'

  spec.add_dependency "multi_json", "~> 1.7"
  spec.add_dependency "virtus", "~> 1.0"
  spec.add_dependency "iso8601", "0.8.7"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "yard"
end
