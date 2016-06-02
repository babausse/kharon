module Kharon
  module Processors
    
    # Processor to validate arrays. It has the :contains option plus the default ones.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class ArrayProcessor < Kharon::Processor

      Kharon.add_processor(:array, Kharon::Processors::ArrayProcessor)

      # Checks if the given key is a datetime or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a datetime, and depends on two other keys.
      #   @validator.datetime(:a_datetime, dependencies: [:another_key, :a_third_key])
      def process(key, options = {})
        before_all(key, options)
        is_typed?(key, Array) ? store(key, ->(item){item.to_a}, options) : raise_type_error(key, "Array")
      end

      # Stores an array after verifying that it contains the values given in the contains? option.
      # @param [Object] key the key associated with the value to store in the filtered datas.
      # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
      # @param [Hash]   options the options applied to the initial value.
      def store(key, process, options)
        contains?(key, validator.datas[key], options[:contains]) if(options.has_key?(:contains))
        super(key, process, options)
      end
    end
  end
end