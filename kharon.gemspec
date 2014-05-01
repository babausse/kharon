Gem::Specification.new do |specification|
  specification.name        = "kharon"
  specification.version     = "0.0.2"
  specification.date        = "2014-04-01"
  specification.summary     = "Ruby Hash validator"
  specification.description = "Charon let you pass or not pass depending if you meet the criterias for this... Or not."
  specification.authors     = ["Vincent Courtois"]
  specification.email       = "vincent.courtois@mycar-innovations.com"
  specification.files       = ["lib/validator.rb", "lib/validate.rb"]
  specification.homepage    = "https://rubygems.org/gems/kharon"
  specification.license     = "Apache License 2"
  specification.test_files  = ["spec/spec_helper.rb", "spec/lib/validator_spec.rb"]

  specification.required_ruby_version = ">= 2.1.0"
  
  specification.add_runtime_dependency "aquarium", ["= 0.5.1"]
end