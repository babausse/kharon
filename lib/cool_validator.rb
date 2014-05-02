require "./lib/validator.rb"

module Kharon
  # This validator is really cooler than the other one. It will help you validate datas without raising exception, if you don't want to.
  # @author Vincent Courtois <vincent.courtois@mycar-innovations.com>
  class CoolValidator < Kharon::Validator

    # @!attribute [r] errors
      # @return an array of strings, each string representing an error occured while validating the hash.
    attr_reader :errors

    # Constructor of the classe, receiving the datas to validate and filter.
    # @param [Hash] datas the datas to validate in the validator.
    # @example create a new instance of validator.
    #   @validator = Kharon::CoolValidator.new({key: "value"})
    def initialize(datas)
      super(datas)
      @errors = Array.new
    end

    # Fancy method to see if the validator have seen an error in the given hash.
    def has_errors?
      return (@errors.empty? ? false : true)
    end

    protected

    def raise_error(message)
      errors.push(message)
    end
  end
end