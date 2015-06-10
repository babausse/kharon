module Kharon
  module Errors

    # Standard exception raised in case the exceptions are used, and there is an error in the validation.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class Validation < Exception

      # @!attribute [rw] error_hash
        # @return [Hash] the description of the encountered error as a Hash.
      attr_accessor :error_hash

      # Constructor of the class.
      # @param [Hash] error_hash the description of the encountered error as a Hash.
      def initialize(error_hash)
        @error_hash = error_hash
      end

      # Generates a JSON version of the encountered error description hash.
      # @return [String] the JSON representation of an error.
      def message
        JSON.generate(error_hash)
      end
    end
  end
end