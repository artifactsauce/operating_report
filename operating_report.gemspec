# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'operating_report/version'

Gem::Specification.new do |spec|
  spec.name          = "operating_report"
  spec.version       = OperatingReport::VERSION
  spec.authors       = ["Kenji Akiyama"]
  spec.email         = ["artifactsauce@gmail.com"]
  spec.summary       = %q{A command line tool to handle operating reports.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/artifactsauce/operating_report"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "awesome_print"
end
