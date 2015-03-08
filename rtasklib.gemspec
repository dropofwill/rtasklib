# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rtasklib/version'

Gem::Specification.new do |spec|
  spec.name          = "rtasklib"
  spec.version       = Rtasklib::VERSION
  spec.authors       = ["Will Paul"]
  spec.email         = ["whp3652@rit.edu"]

  spec.summary       = %q{A Ruby wrapper around the TaskWarrior CLI, based on the Python tasklib}
  spec.description   = %q{A Ruby wrapper around the TaskWarrior CLI, based on the Python tasklib. Requires a working TaskWarrior install.}
  spec.homepage      = "http://github.com/dropofwill/rtasklib"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  #.reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "virtus"
  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"
  spec.add_dependency "active_model_serializers"
  # spec.add_dependency "ice_nine"
  # spec.add_dependency "oj"
  # spec.add_dependency "iso8601"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
