Gem::Specification.new do |specification|
  specification.name        = "kharon"
  specification.version     = "0.2.0"
  specification.date        = "2014-04-02"
  specification.summary     = "Ruby Hash validator"
  specification.description = "Kharon is a ruby hash validator that helps you fix the structure of a hash (type of the keys, dependencies, ...)."
  specification.authors     = ["Vincent Courtois"]
  specification.email       = "vincent.courtois@mycar-innovations.com"
  specification.files       = ["lib/validator.rb", "lib/validate.rb"]
  specification.homepage    = "https://rubygems.org/gems/kharon"
  specification.license     = "Apache License 2"
  specification.test_files  = ["spec/lib/validator_spec.rb"]

  specification.required_ruby_version = ">= 1.9.3"
end