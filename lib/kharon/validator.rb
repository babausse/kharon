module Kharon

  # The validator is the main class of Kharon, it validates a hash given a structure.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Validator

    # @!attribute [r] datas
      # @return [Hash] The datas to filter, they shouldn't be modified to guarantee their integrity.
    attr_reader :datas

    # @!attribute [rw] filtered
      # @return [Hash] The filtered datas are the datas after they have been filtered (renamed keys for example) by the validator.
    attr_accessor :filtered

    # @!attribute [rw] handler
      # @return [Object] the error handler given to this instance of the validator.
    attr_accessor :handler

    # Constructor of the classe, receiving the datas to validate and filter.
    # @param [Hash] datas the datas to validate in the validator.
    # @example create a new instance of validator.
    #   @validator = Kharon::Validator.new({key: "value"})
    def initialize(datas)
      @datas    = datas
      @filtered = Hash.new
      @handler  = Kharon.errors_handler
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

    # Checks if the given key is a box (geofences) or not. A box is composed of four numbers (positive or negative, decimal or not) separed by commas.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a box.
    #   @validator.box(:a_box)
    def box(key, options = {})
      before_all(key, options)
      match?(key, /^(?:[+-]?\d{1,3}(?:\.\d{1,7})?,?){4}$/) ? store_box(key, options) : raise_type_error(key, "Box")
    end

    # Checks if the given key is an email or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be an email.
    #   @validator.email(:email)
    def email(key, options = {})
      before_all(key, options)
      match?(key, /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/) ? store(key, ->(item){item}, options) : raise_type_error(key, "Email")
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
      if options.has_key?(:round)
        store_rounded_decimal(key, process, options)
      elsif(options.has_key?(:floor) and options[:floor] == true)
        filtered[key] = filtered[key].floor if filtered.has_key?(key)
      elsif(options.has_key?(:ceil) and options[:ceil] == true)
        filtered[key] = filtered[key].ceil if filtered.has_key?(key)
      end
    end

    # Stores a decimal after rounding it with the convenient number of decimals.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value.
    def store_rounded_decimal(key, process, options)
      if options[:round].kind_of?(Integer)
        filtered[key] = filtered[key].round(options[:round]) if filtered.has_key?(key)
      elsif options[:round] == true
        filtered[key] = filtered[key].round if filtered.has_key?(key)
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

    def store_box(key, options)
      if(options.has_key?(:at_least))
        box_contains?(key, datas[key], options[:at_least])
      end
      if(options.has_key?(:at_most))
        box_contains?(key, options[:at_most], datas[key])
      end
      store(key, ->(item){parse_box(key, datas[key])}, options)
    end

    # Checks if a required key is present in provided datas.
    # @param [Object] key the key of which check the presence.
    # @raise [ArgumentError] if the key is not present.
    def required(key)
      raise_error(type: "required", key: key) unless @datas.has_key?(key)
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
      raise_error(type: "dependency", key: "key", needed: dependency) unless @datas.has_key?(dependency)
    end

    # Checks if the value associated with the given key is greater than the given minimum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] min_value the required minimum value.
    # @raise [ArgumentError] if the initial value is strictly lesser than the minimum value.
    def check_min_value(key, min_value)
      raise_error(type: "min", supposed: min_value, key: key, value: datas[key]) unless datas[key].to_i >= min_value.to_i
    end

    # Checks if the value associated with the given key is lesser than the given maximum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] max_value the required maximum value.
    # @raise [ArgumentError] if the initial value is strictly greater than the minimum value.
    def check_max_value(key, max_value)
      raise_error(type: "max", supposed: max_value, key: key, value: datas[key]) unless datas[key].to_i <= max_value.to_i
    end

    # Checks if the value associated with the given key is included in the given array of values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  values the values in which the initial value should be contained.
    # @raise [ArgumentError] if the initial value is not included in the given possible values.
    def in_array?(key, values)
      raise_error(type: "array.in", key: key, supposed: values, value: datas[key]) unless (values.empty? or values.include?(datas[key]))
    end

    # Checks if the value associated with the given key is equal to the given value.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the values with which the initial value should be compared.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_to?(key, value)
      raise_error(type: "equals", key: key, supposed: value, found: datas[key]) unless datas[key] == value
    end

    # Checks if the value associated with the given key is equal to the given key.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the key to compare the currently validated key with.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_key?(key, value)
      raise_error(type: "equals", key: key, supposed: datas[value], found: datas[key]) unless datas[key] == datas[value]
    end

    # Checks if the value associated with the given key has the given required keys.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the keys that the initial Hash typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given keys.
    def has_keys?(key, required_keys)
      raise_error(type: "contains.keys", required: required_keys, key: key) if (datas[key].keys & required_keys) != required_keys
    end

    # Checks if the value associated with the given key has the given required values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_values the values that the initial Enumerable typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given values.
    def contains?(key, values, required_values)
      raise_error(type: "contains.values", required: required_values, key: key) if (values & required_values) != required_values
    end

    def match_regex?(key, value, regex)
      regex = Regexp.new(regex) if regex.kind_of?(String)
      raise_error(type: "regex", regex: regex, value: value, key: key) unless regex.match(value)
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
          elsif(options.has_key?(:equals_key))
            equals_key?(key, options[:equals_key])
          end
          options.has_key?(:rename) ? (@filtered[options[:rename]] = value) : (@filtered[key] = value)
        end
      end
    end

    # Parses a box given as a string of four numbers separated by commas.
    # @param [String] box the string representing the box.
    # @return [Array] an array of size 2, containing two arrays of size 2 (the first being the coordinates of the top-left corner, the second the ones of the bottom-right corner)
    def parse_box(key, box)
      if box.kind_of?(String)
        begin
          raw_box = box.split(",").map(&:to_f)
          box = [[raw_box[0], raw_box[1]], [raw_box[2], raw_box[3]]]
        rescue
          raise_error(type: "box.format", key: "key", value: box)
        end
      end
      return box
    end

    # Verify if a box contains another box.
    # @param [Object] container any object that can be treated as a box, container of the other box
    # @param [Object] contained any object that can be treated as a box, contained in the other box
    # @return [Boolean] TRUE if the box is contained in the other one, FALSE if not.
    def box_contains?(key, container, contained)
      container = parse_box(key, container)
      contained = parse_box(key, contained)
      result = ((container[0][0] <= contained[0][0]) and (container[0][1] <= container[0][1]) and (container[1][0] >= container[1][0]) and (container[1][1] >= container[1][1]))
      raise_error(type: "box.containment", contained: contained, container: container, key: key) unless result
    end

    # Raises a type error with a generic message.
    # @param [Object] key the key associated from the value triggering the error.
    # @param [Class]  type the expected type, not respected by the initial value.
    # @raise [ArgumentError] the chosen type error.
    def raise_type_error(key, type)
      raise_error(type: "type", key: key, supposed: type, found: key.class)
    end

    protected

    # Raises an error giving a message to display.
    # @param [String] message the the message to display with the exception.
    # @raise ArgumentError an error to stop the execution when this method is invoked.
    def raise_error(message)
      handler.report_error(message)
    end

    # Accessor for the errors, use only if the handler is a Kharon::Handlers::Messages.
    # @return [Array] the errors encountered during validation or an empty array if the handler was a Kharon::Handlers::Exceptions.
    def errors
      handler.respond_to?(:errors) ? handler.errors : []
    end

  end
end