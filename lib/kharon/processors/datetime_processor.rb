module Kharon
  module Processors

    # Processor to validate datetimes. It only has the default options.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class DatetimeProcessor < Kharon::Processor

      Kharon.add_processor(:datetime, Kharon::Processors::DatetimeProcessor)

      # Checks if the given key is a datetime or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a datetime, and depends on two other keys.
      #   @validator.datetime(:a_datetime, dependencies: [:another_key, :a_third_key])
      def process(key, options = {})
        before_all(key, options)
        begin; store(key, ->(item){DateTime.parse(item.to_s)} , options); rescue; raise_type_error(key, "DateTime"); end
      end
    end
  end
end