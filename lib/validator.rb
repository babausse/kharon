module Kharon
  # The validator is the main class of Kharon, it validates a hash given a structure.
  # @author Vincent Courtois <vincent.courtois@mycar-innovations.com>
  class Validator

    # @!attribute [r] datas
      # @return The datas to filter, they shouldn't be modified to guarantee their integrity.
    attr_reader :datas

    # @!attribute [rw] filtered
      # @return The filtered datas are the datas after they have been filtered (renamed keys for example) by the validator.
    attr_accessor :filtered

    # Constructor of the classe, receiving the datas to validate and filter.
    # @param [Hash] datas the datas to validate in the validator.
    # @example create a new instance of validator.
    #   @validator = Kharon::Validator.new({key: "value"})
    def initialize(datas)
      @datas    = datas
      @filtered = Hash.new
    end

    # Checks if the given key is an integer or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be an integer superior or equal to 2.
    #   @validator.integer(:an_integer_key, min: 2)
    def integer(key, options = {})
      before_all(key, options)
      match?(key, /\A\d+\Z/) ? store_numeric(key, ->(item){item.to_i}, options) : raise_type_error(key, "Integer")
    end

    # Checks if the given key is a numeric or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a numeric, is required and is between 2 and 5.5.
    #   @validator.numeric(:a_numeric_key, required: true, between: [2, 5.5])
    def numeric(key, options = {})
      before_all(key, options)
      match?(key, /\A([+-]?\d+)([,.](\d+))?\Z/) ? store_decimal(key, ->(item){item.to_s.sub(/,/, ".").to_f}, options) : raise_type_error(key, "Numeric")
    end

    # Checks if the given key is a not-empty string or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a string, and seems like and email address (not sure of the regular expression though).
    #   @validator.text(:an_email, regex: "[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]{2-4}")
    def text(key, options = {})
      before_all(key, options)
      is_typed?(key, String) ? store_text(key, ->(item){item.to_s}, options) : raise_type_error(key, "String")
    end

    # Doesn't check the type of the key and let it pass without modification.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Just checks if the key is in the hash.
    #   @validator.any(:a_key, required: true)
    def any(key, options = {})
      before_all(key, options)
      store(key, ->(item){item}, options)
    end

    # Checks if the given key is a datetime or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a datetime, and depends on two other keys.
    #   @validator.datetime(:a_datetime, dependencies: [:another_key, :a_third_key])
    def datetime(key, options = {})
      before_all(key, options)
      begin; store(key, ->(item){DateTime.parse(item.to_s)} , options); rescue; raise_type_error(key, "DateTime"); end
    end

    # Checks if the given key is a date or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a date, and depends on another key.
    #   @validator.date(:a_date, dependency: :another_key)
    def date(key, options = {})
      before_all(key, options)
      begin; store(key, ->(item){Date.parse(item.to_s)}, options); rescue; raise_type_error(key, "Date"); end
    end

    # Checks if the given key is an array or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be an array, and checks if it has some values in it.
    #   @validator.date(:an_array, contains?: ["first", "second"])
    def array(key, options = {})
      before_all(key, options)
      is_typed?(key, Array) ? store_array(key, ->(item){item.to_a}, options) : raise_type_error(key, "Array")
    end

    # Checks if the given key is a hash or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a hash, and checks if it has some keys.
    #   @validator.date(:a_hash, has_keys: [:first, :second])
    def hash(key, options = {})
      before_all(key, options)
      is_typed?(key, Hash) ? store_hash(key, ->(item){Hash.try_convert(item)}, options) : raise_type_error(key, "Hash")
    end

    # Checks if the given key is a boolean or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a boolean.
    #   @validator.boolean(:a_boolean)
    def boolean(key, options = {})
      before_all(key, options)
      match?(key, /(true)|(false)/) ? store(key, ->(item){to_boolean(item)}, options) : raise_type_error(key, "Numeric")
    end

    # Checks if the given key is a SSID for a MongoDB object or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a MongoDB SSID.
    #   @validator.ssid(:a_ssid)
    def ssid(key, options = {})
      before_all(key, options)
      match?(key, /^[0-9a-fA-F]{24}$/) ? store(key, ->(item){BSON::ObjectId.from_string(item.to_s)}, options) : raise_type_error(key, "Moped::BSON::ObjectId")
    end

    private

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

    # Stores a numeric number after checking its limits if given.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_numeric(key, process, options)
      if(options.has_key?(:between))
        check_min_value(key, options[:between][0])
        check_max_value(key, options[:between][1])
      else
        check_min_value(key, options[:min]) if(options.has_key?(:min))
        check_max_value(key, options[:max]) if(options.has_key?(:max))
      end
      store(key, process, options)
    end

    # Stores a decimal number, then apply the eventually passed round, ceil, or floor options.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_decimal(key, process, options)
      store_numeric(key, process, options)
      if(options.has_key?(:round) and options[:round].kind_of?(Integer))
        filtered[key] = filtered[key].round(options[:round]) if filtered.has_key?(key)
      elsif(options.has_key?(:floor) and options[:floor] == true)
        filtered[key] = filtered[key].floor if filtered.has_key?(key)
      elsif(options.has_key?(:ceil) and options[:ceil] == true)
        filtered[key] = filtered[key].ceil if filtered.has_key?(key)
      end
    end

    # Stores a hash after checking for the contains? and has_keys options.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_hash(key, process, options)
      has_keys?(key, options[:has_keys]) if(options.has_key?(:has_keys))
      contains?(filtered, datas[key].values, options[:contains]) if(options.has_key?(:contains))
      store(key, process, options)
    end

    # Stores an array after verifying that it contains the values given in the contains? option.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_array(key, process, options)
      contains?(key, datas[key], options[:contains]) if(options.has_key?(:contains))
      store(key, process, options)
    end

    # Stores a string after verifying that it respects a regular expression given in parameter.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_text(key, process, options)
      match_regex?(key, datas[key], options[:regex]) if(options.has_key?(:regex))
      store(key, process, options)
    end

    # Checks if a required key is present in provided datas.
    # @param [Object] key the key of which check the presence.
    # @raise [ArgumentError] if the key is not present.
    def required(key)
      raise_error("The key #{key} is required and not provided.") unless @datas.has_key?(key)
    end

    # Syntaxic sugar used to chack several dependencies at once.
    # @param [Object] key the key needing another key to properly work.
    # @param [Object] dependency the key needed by another key for it to properly work.
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
      raise_error("The key #{key} needs the key #{dependency} but it was not provided.") unless @datas.has_key?(dependency)
    end

    # Checks if the value associated with the given key is greater than the given minimum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] min_value the required minimum value.
    # @raise [ArgumentError] if the initial value is strictly lesser than the minimum value.
    def check_min_value(key, min_value)
      raise_error("The key #{key} was supposed to be greater or equal than #{min_value}, the value was #{datas[key]}") unless datas[key].to_i >= min_value.to_i
    end

    # Checks if the value associated with the given key is lesser than the given maximum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] max_value the required maximum value.
    # @raise [ArgumentError] if the initial value is strictly greater than the minimum value.
    def check_max_value(key, max_value)
      raise_error("The key #{key} was supposed to be lesser or equal than #{max_value}, the value was #{datas[key]}") unless datas[key].to_i <= max_value.to_i
    end

    # Checks if the value associated with the given key is included in the given array of values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  values the values in which the initial value should be contained.
    # @raise [ArgumentError] if the initial value is not included in the given possible values.
    def in_array?(key, values)
      raise_error("The key #{key} was supposed to be in [#{values.join(", ")}], the value was #{datas[key]}") unless (values.empty? or values.include?(datas[key]))
    end

    # Checks if the value associated with the given key is equal to the given value.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the values with which the initial value should be compared.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_to?(key, value)
      raise_error("The key #{key} was supposed to equal than #{value}, the value was #{datas[key]}") unless datas[key] == value
    end

    # Checks if the value associated with the given key has the given required keys.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the keys that the initial Hash typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given keys.
    def has_keys?(key, required_keys)
      raise_error("The key #{key} was supposed to contains keys [#{required_keys.join(", ")}]") if (datas[key].keys & required_keys) != required_keys
    end

    # Checks if the value associated with the given key has the given required values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the values that the initial Enumerable typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given values.
    def contains?(key, values, required_values)
      raise_error("The key #{key} was supposed to contains values [#{required_values.join(", ")}]") if (values & required_values) != required_values
    end

    def match_regex?(key, value, regex)
      regex = Regexp.new(regex) if regex.kind_of?(String)
      raise_error("The key #{key} was supposed to match the regex #{regex} but its value was #{value}") unless regex.match(value)
    end

    # Check if the value associated with the given key matches the given regular expression.
    # @param [Object]   key the key of the value to compare with the given regexp.
    # @param [Regexp]   regex the regex with which match the initial value.
    # @return [Boolean] true if the initial value matches the regex, false if not.
    def match?(key, regex)
      return (!datas.has_key?(key) or datas[key].to_s.match(regex))
    end

    # Check if the value associated with the given key is typed with the given type, or with a type inheriting from it.
    # @param [Object]   key the key of the value to check the type from.
    # @param [Class]    type the type with which check the initial value.
    # @return [Boolean] true if the initial value is from the right type, false if not.
    def is_typed?(key, type)
      return (!datas.has_key?(key) or datas[key].kind_of?(type))
    end

    # Transforms a given value in a boolean.
    # @param [Object] value the value to transform into a boolean.
    # @return [Boolean] true if the value was true, 1 or yes, false if not.
    def to_boolean(value)
      ["true", "1", "yes"].include?(value.to_s) ? true : false
    end

    # Tries to store the associated key in the filtered key, transforming it with the given process.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store(key, process, options = {})
      unless (options.has_key?(:extract) and options[:extract] == false)
        if datas.has_key?(key)
          value = ((options.has_key?(:cast) and options[:cast] == false) ? datas[key] : process.call(datas[key]))
          if(options.has_key?(:in))
            in_array?(key, options[:in])
          elsif(options.has_key?(:equals))
            equals_to?(key, options[:equals])
          end
          options.has_key?(:rename) ? (@filtered[options[:rename]] = value) : (@filtered[key] = value)
        end
      end
    end

    # Raises a type error with a generic message.
    # @param [Object] key the key associated from the value triggering the error.
    # @param [Class]  type the expected type, not respected by the initial value.
    # @raise [ArgumentError] the chosen type error.
    def raise_type_error(key, type)
      raise_error("The key {key} was supposed to be an instance of #{type}, #{key.class} found.")
    end

    protected

    def raise_error(message)
      raise ArgumentError.new(message)
    end

  end
end