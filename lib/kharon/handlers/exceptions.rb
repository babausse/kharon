module Kharon
  module Handlers

    # Errors handler that raises exception as soon as a problem is encountered during validation.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class Exceptions
      include Singleton

      # Method used to report an error by raising the correct type of exception.
      # @param [Hash] error_hash a Hash describing the error.
      # @raises [Kharon::Errors::Validation] the exception raised when an error is encountered.
      def report_error(error_hash)
        raise Kharon::Errors::Validation.new(error_hash)
      end
    end
  end
end