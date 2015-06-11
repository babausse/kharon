module Kharon
  module Handlers

    # Errors handler that stores each problem encountered during validation.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class Messages

      # Constructor of the class, initializing the errors array.
      def initialize
        @errors = Array.new
      end

      # Method used to report an error by storing it in an array.
      # @param [Hash] error_hash a Hash describing the error.
      # @return [Kharon::Handlers::Messages] the errors handler after insertion, so several calls can be chained.
      def report_error(error_hash)
        @errors.push(error_hash)
        self
      end

      # Getter for the errors, cloning it so no error can be added from outside of the report_error method
      # @return [Array] the array of errors.
      def errors
        @errors.clone
      end
    end
  end
end