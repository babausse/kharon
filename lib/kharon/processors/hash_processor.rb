module Kharon
  module Processors

    # Processor to validate hashes. It has the :has_keys and :contains options with the default ones.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class HashProcessor < Kharon::Processor

      Kharon.add_processor(:hash, Kharon::Processors::HashProcessor)

      # Checks if the given key is a datetime or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a datetime, and depends on two other keys.
      #   @validator.datetime(:a_datetime, dependencies: [:another_key, :a_third_key])
      def process(key, options = {})
        before_all(key, options)
        is_typed?(key, Hash) ? store(key, ->(item){Hash.try_convert(item)}, options) : raise_type_error(key, "Hash")
      end

      # Stores an array after verifying that it contains the values given in the contains? option.
      # @param [Object] key the key associated with the value to store in the filtered datas.
      # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
      # @param [Hash]   options the options applied to the initial value.
      def store(key, process, options)
        has_keys?(key, options[:has_keys]) if(options.has_key?(:has_keys))
        contains?(validator.filtered, validator.datas[key].values, options[:contains]) if(options.has_key?(:contains))
        super(key, process, options)
      end
    end
  end
end