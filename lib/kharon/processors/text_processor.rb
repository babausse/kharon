module Kharon
  module Processors

    # Processor to validate simple strings. It has the :regex option plus the default ones.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class TextProcessor < Kharon::Processor

      Kharon.add_processor(:text, Kharon::Processors::TextProcessor)

      # Checks if the given key is a not-empty string or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a string, and seems like and email address (not sure of the regular expression though).
      #   @validator.text(:an_email, regex: "[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]{2-4}")
      def process(key, options = {})
        before_all(key, options)
        is_typed?(key, String) ? store(key, ->(item){item.to_s}, options) : raise_type_error(key, "String")
      end

      # Stores a string after verifying that it respects a regular expression given in parameter.
      # @param [Object] key the key associated with the value to store in the filtered datas.
      # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
      # @param [Hash]   options the options applied to the initial value.
      def store(key, process, options)
        match_regex?(key, validator.datas[key], options[:regex]) if(options.has_key?(:regex))
        super(key, process, options)
      end
    end
  end
end