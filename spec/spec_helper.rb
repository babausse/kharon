# Sets the environment variable to test before loading all the files.
ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'mocha/api'
require 'aquarium'
require 'moped'

module RSpec
  configure do |configuration|
    # Configuration rspec to use mocha as mocking API.
    configuration.mock_with :mocha
  end
end