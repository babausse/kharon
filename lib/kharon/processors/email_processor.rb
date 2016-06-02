module Kharon
  module Processors

    # Processor to validate emails. It only has the default options.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class EmailProcessor < Kharon::Processor

      Kharon.add_processor(:email, Kharon::Processors::EmailProcessor)

      # Checks if the given key is a not-empty string or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a string, and seems like and email address (not sure of the regular expression though).
      #   @validator.text(:an_email, regex: "[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]{2-4}")
      def process(key, options = {})
        before_all(key, options)
        match?(key, /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/) ? store(key, ->(item){item}, options) : raise_type_error(key, "Email")
      end
    end
  end
end