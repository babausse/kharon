Gem::Specification.new do |specification|
  specification.name        = "kharon"
  specification.version     = "0.1.0"
  specification.date        = "2014-04-02"
  specification.summary     = "Ruby Hash validator"
  specification.description = "Kharon is a ruby hash validator that helps you fix the structure of a hash (type of the keys, dependencies, ...)."
  specification.authors     = ["Vincent Courtois"]
  specification.email       = "vincent.courtois@mycar-innovations.com"
  specification.files       = ["lib/validator.rb", "lib/validate.rb"]
  specification.homepage    = "https://rubygems.org/gems/kharon"
  specification.license     = "Apache License 2"
  specification.test_files  = ["spec/spec_helper.rb", "spec/lib/validator_spec.rb"]

  specification.required_ruby_version = ">= 1.9.3"
  
  specification.add_runtime_dependency "aquarium", ["= 0.5.1"]
end