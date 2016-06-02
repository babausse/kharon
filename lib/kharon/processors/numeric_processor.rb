module Kharon
  module Processors

    # Processor to validate integers. It has the :between, :round, :floor, :ceil, :min, and :max options with the default ones.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class NumericProcessor < Kharon::Processor

      Kharon.add_processor(:numeric, Kharon::Processors::NumericProcessor)

      # Checks if the given key is an integer or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be an integer superior or equal to 2.
      #   @validator.integer(:an_integer_key, min: 2)
      def process(key, options = {})
        before_all(key, options)
        match?(key, /\A([+-]?\d+)([,.](\d+))?\Z/) ? store(key, ->(item){item.to_s.sub(/,/, ".").to_f}, options) : raise_type_error(key, "Numeric")
      end

      # Stores a decimal number, then apply the eventually passed round, ceil, or floor options.
      # @param [Object] key the key associated with the value to store in the filtered datas.
      # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
      # @param [Hash]   options the options applied to the initial value.
      def store(key, process, options)
        if(options.has_key?(:between))
          check_min_value(key, options[:between][0])
          check_max_value(key, options[:between][1])
        else
          check_min_value(key, options[:min]) if(options.has_key?(:min))
          check_max_value(key, options[:max]) if(options.has_key?(:max))
        end
        super(key, process, options)
        if options.has_key?(:round)
          if options[:round].kind_of?(Integer)
            validator.filtered[key] = validator.filtered[key].round(options[:round]) if validator.filtered.has_key?(key)
          elsif options[:round] == true
            validator.filtered[key] = validator.filtered[key].round if validator.filtered.has_key?(key)
          end
        elsif(options.has_key?(:floor) and options[:floor] == true)
          validator.filtered[key] = validator.filtered[key].floor if validator.filtered.has_key?(key)
        elsif(options.has_key?(:ceil) and options[:ceil] == true)
          validator.filtered[key] = validator.filtered[key].ceil if validator.filtered.has_key?(key)
        end
      end

      private

      # Checks if the value associated with the given key is greater than the given minimum value.
      # @param [Object]  key the key associated with the value to compare.
      # @param [Numeric] min_value the required minimum value.
      # @raise [ArgumentError] if the initial value is strictly lesser than the minimum value.
      def check_min_value(key, min_value)
        raise_error(type: "min", supposed: min_value, key: key, value: validator.datas[key]) unless validator.datas[key].to_i >= min_value.to_i
      end

      # Checks if the value associated with the given key is lesser than the given maximum value.
      # @param [Object]  key the key associated with the value to compare.
      # @param [Numeric] max_value the required maximum value.
      # @raise [ArgumentError] if the initial value is strictly greater than the minimum value.
      def check_max_value(key, max_value)
        raise_error(type: "max", supposed: max_value, key: key, value: validator.datas[key]) unless validator.datas[key].to_i <= max_value.to_i
      end

    end
  end
end
