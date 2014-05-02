require "./lib/validator.rb"
require "./lib/cool_validator.rb"

module Kharon
  module Factory

    # @!attribute [r|w] use_exceptions
      # @return TRUE if Kharon currently use exceptions, FALSE if not.
    @@use_exceptions = true

    # Acts as a creation method for validators, considering the options you transmitted.
    # @param [Hash] datas the datas to validate in the validator.
    def self.validator(datas)
      @@use_exceptions ? Kharon::Validator.new(datas) : Kharon::CoolValidator.new(datas)
    end

    # Allows you to pass a whole block to configure the Kharon module.
    # @param [Hash] block a block of configuration instructions to pass to the module. See documentation for further informations.
    def self.configure(&block)
      self.instance_eval(&block)
    end

    # Sets the use of exceptions in the whole process.
    # @param [Boolean] status TRUE if you want to use the eceptions, FALSE if not.
    def self.use_exceptions(status)
      @@use_exceptions = status
    end

    # Fancy method to know if the module uses the exceptions or not.
    def self.uses_exceptions?
      return @@use_exceptions
    end
  end
end