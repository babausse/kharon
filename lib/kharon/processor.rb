module Kharon
  # A basic processor used to be subclassed by all different processors.
  # It provides basic informations to process a hash key validation.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Processor

    Kharon.add_processor(:any, Kharon::Processor)

    attr_accessor :validator

    def initialize(validator)
      @validator = validator
    end

    # Default processing method, simply storing the validated key in the filtered hash.
    # @param [Object] key the key associated with the value currently filteres in the filtered datas.
    # @param [Hash]   options the options applied to the initial value.
    def process(key, options = {})
      store(key, ->(item){item}, options)
    end

    protected

    # This method is executed before any call to a public method.
    # @param [Object] key the key associated with the value currently filteres in the filtered datas.
    # @param [Hash]   options the options applied to the initial value.
    def before_all(key, options)
      required(key) if (options.has_key?(:required) and options[:required] == true)
      if options.has_key?(:dependencies)
        dependencies(key, options[:dependencies])
      elsif options.has_key?(:dependency)
        dependency(key, options[:dependency])
      end
    end

    # Tries to store the associated key in the filtered key, transforming it with the given process.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store(key, process, options = {})
      unless (options.has_key?(:extract) and options[:extract] == false)
        if validator.datas.has_key?(key)
          value = ((options.has_key?(:cast) and options[:cast] == false) ? validator.datas[key] : process.call(validator.datas[key]))
          if(options.has_key?(:in))
            in_array?(key, options[:in])
          elsif(options.has_key?(:equals))
            equals_to?(key, options[:equals])
          elsif(options.has_key?(:equals_key))
            equals_key?(key, options[:equals_key])
          end
          options.has_key?(:rename) ? (validator.filtered[options[:rename]] = value) : (validator.filtered[key] = value)
        end
      end
    end

    # Raises a type error with a generic message.
    # @param [Object] key the key associated from the value triggering the error.
    # @param [Class]  type the expected type, not respected by the initial value.
    # @raise [ArgumentError] the chosen type error.
    def raise_type_error(key, type)
      raise_error(type: "type", key: key, supposed: type, found: key.class)
    end

    # Raises an error giving a message to display.
    # @param [String] message the the message to display with the exception.
    # @raise ArgumentError an error to stop the execution when this method is invoked.
    def raise_error(message)
      validator.handler.report_error(message)
    end

    # Accessor for the errors, use only if the handler is a Kharon::Handlers::Messages.
    # @return [Array] the errors encountered during validation or an empty array if the handler was a Kharon::Handlers::Exceptions.
    def errors
      validator.handler.respond_to?(:errors) ? validator.handler.errors : []
    end

    # Checks if a required key is present in provided datas.
    # @param [Object] key the key of which check the presence.
    # @raise [ArgumentError] if the key is not present.
    def required(key)
      raise_error(type: "required", key: key) unless validator.datas.has_key?(key)
    end

    # Syntaxic sugar used to chack several dependencies at once.
    # @param [Object] key the key needing another key to properly work.
    # @param [Object] dependencies the keys needed by another key for it to properly work.
    # @raise [ArgumentError] if the required dependencies are not present.
    # @see self#check_dependency the associated singular method.
    def dependencies(key, dependencies)
      dependencies.each { |dependency| dependency(key, dependency) }
    end

    # Checks if a dependency is respected. A dependency is a key openly needed by another key.
    # @param [Object] key the key needing another key to properly work.
    # @param [Object] dependency the key needed by another key for it to properly work.
    # @raise [ArgumentError] if the required dependency is not present.
    def dependency(key, dependency)
      raise_error(type: "dependency", key: "key", needed: dependency) unless validator.datas.has_key?(dependency)
    end

    # Check if the value associated with the given key is typed with the given type, or with a type inheriting from it.
    # @param [Object]   key the key of the value to check the type from.
    # @param [Class]    type the type with which check the initial value.
    # @return [Boolean] true if the initial value is from the right type, false if not.
    def is_typed?(key, type)
      return (!validator.datas.has_key?(key) or validator.datas[key].kind_of?(type))
    end

    # Checks if the value associated with the given key is included in the given array of values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  values the values in which the initial value should be contained.
    # @raise [ArgumentError] if the initial value is not included in the given possible values.
    def in_array?(key, values)
      raise_error(type: "array.in", key: key, supposed: values, value: validator.datas[key]) unless (values.empty? or values.include?(validator.datas[key]))
    end

    # Checks if the value associated with the given key is equal to the given value.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the values with which the initial value should be compared.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_to?(key, value)
      raise_error(type: "equals", key: key, supposed: value, found: validator.datas[key]) unless validator.datas[key] == value
    end

    # Checks if the value associated with the given key is equal to the given key.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the key to compare the currently validated key with.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_key?(key, value)
      raise_error(type: "equals", key: key, supposed: validator.datas[value], found: validator.datas[key]) unless validator.datas[key] == validator.datas[value]
    end

    # Check if the value associated with the given key matches the given regular expression.
    # @param [Object]   key the key of the value to compare with the given regexp.
    # @param [Regexp]   regex the regex with which match the initial value.
    # @return [Boolean] true if the initial value matches the regex, false if not.
    def match?(key, regex)
      return (!validator.datas.has_key?(key) or validator.datas[key].to_s.match(regex))
    end

    def match_regex?(key, value, regex)
      regex = Regexp.new(regex) if regex.kind_of?(String)
      raise_error(type: "regex", regex: regex, value: value, key: key) unless regex.match(value)
    end

    # Checks if the value associated with the given key has the given required values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_values the values that the initial Enumerable typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given values.
    def contains?(key, values, required_values)
      raise_error(type: "contains.values", required: required_values, key: key) if (values & required_values) != required_values
    end

    # Checks if the value associated with the given key has the given required keys.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the keys that the initial Hash typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given keys.
    def has_keys?(key, required_keys)
      raise_error(type: "contains.keys", required: required_keys, key: key) if (validator.datas[key].keys & required_keys) != required_keys
    end
  end
end