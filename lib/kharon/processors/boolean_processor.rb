module Kharon
  module Processors

    # Processor to validate booleans. It only has the default options.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class BooleanProcessor < Kharon::Processor

      Kharon.add_processor(:boolean, Kharon::Processors::BooleanProcessor)

      # Checks if the given key is a boolean or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a boolean.
      #   @validator.boolean(:a_boolean)
      def process(key, options = {})
        before_all(key, options)
        match?(key, /(true)|(false)/) ? store(key, ->(item){to_boolean(item)}, options) : raise_type_error(key, "Numeric")
      end

      private

      # Transforms a given value in a boolean.
      # @param [Object] value the value to transform into a boolean.
      # @return [Boolean] true if the value was true, 1 or yes, false if not.
      def to_boolean(value)
        ["true", "1", "yes"].include?(value.to_s) ? true : false
      end

    end
  end
end