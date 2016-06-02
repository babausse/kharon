module Kharon
  module Processors

    # Processor to validate dates. It only has the default options.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class DateProcessor < Kharon::Processor

      Kharon.add_processor(:date, Kharon::Processors::DateProcessor)

      # Checks if the given key is a datetime or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a datetime, and depends on two other keys.
      #   @validator.datetime(:a_datetime, dependencies: [:another_key, :a_third_key])
      def process(key, options = {})
        before_all(key, options)
        begin; store(key, ->(item){Date.parse(item.to_s)}, options); rescue; raise_type_error(key, "Date"); end
      end
    end
  end
end