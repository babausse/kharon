# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kharon/version'

Gem::Specification.new do |specification|
  specification.name        = "kharon"
  specification.version     = Kharon::VERSION
  specification.date        = Date.today.strftime("%Y-%m-%d")
  specification.summary     = "Ruby Hash validator"
  specification.description = "Kharon is a ruby hash validator that helps you fix the structure of a hash (type of the keys, dependencies, ...)."
  specification.authors     = ["Vincent Courtois"]
  specification.email       = "courtois.vincent@outlook.com"
  specification.files       = `git ls-files`.split($/)
  specification.homepage    = "https://rubygems.org/gems/kharon"
  specification.license     = "Apache License 2"
  specification.test_files  = ["spec/spec_helper.rb", "spec/lib/kharon/validator_spec.rb"]

  specification.required_ruby_version = ">= 1.9.3"
  specification.add_runtime_dependency "bson", ">= 2.2.2"
end