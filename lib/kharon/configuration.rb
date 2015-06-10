require "singleton"
require "yaml"

module Kharon

  # Simple wrapper for the configuration.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Configuration
    include Singleton

    attr_accessor :configuration

    # Constructor of the configuration, initializes default values for each usable key.
    def initialize
      @configuration = {
        exceptions: true
      }
    end

    def use_exceptions(use = true)
      @configuration[:exceptions] = use
    end

    def uses_exceptions?
      @configuration[:exceptions]
    end
  end
end