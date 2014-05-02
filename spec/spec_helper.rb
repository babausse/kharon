# Sets the environment variable to test before loading all the files.
ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'bson'

require './lib/cool_validator.rb'
require './lib/validator_factory.rb'
require './lib/validator.rb'