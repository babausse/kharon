module Kharon
  # The validator uses aquarium as an AOP DSL to provide "before" and "after" joint point to its main methods.
  # @author Vincent Courtois <vincent.courtois@mycar-innovations.com>
  class Validator
    include Aquarium::DSL

    # @!attribute [r] datas
      # @return The datas to filter, they shouldn't be modified to guarantee their integrity.
    attr_reader :datas

    # @!attribute [rw] filtered
      # @return The filtered datas are the datas after they have been filtered (renamed keys for example) by the validator.
    attr_accessor :filtered

    # Constructor of the classe, receiving the datas to validate and filter.
    # @param [Hash] datas the datas to validate in the validator.
    def initialize(datas)
      @datas    = datas
      @filtered = Hash.new
    end

    # @!group Public_interface

    # Checks if the given key is an integer or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def integer(key, options = {})
      match?(key, /\A\d+\Z/) ? store(key, ->(item){item.to_i}, options) : raise_type_error(key, "Integer")
    end

    # Checks if the given key is a numeric or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def numeric(key, options = {})
      match?(key, /\A([+-]?\d+)([,.](\d+))?\Z/) ? store(key, ->(item){item.sub(/,/, ".").to_f}, options) : raise_type_error(key, "Numeric")
    end

    # Checks if the given key is a not-empty string or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def text(key, options = {})
      is_typed?(key, String) ? store(key, ->(item){item.to_s}, options) : raise_type_error(key, "String")
    end

    # Doesn't check the type of the key and let it pass without modification.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def any(key, options = {})
      store(key, ->(item){item}, options)
    end

    # Checks if the given key is a datetime or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def datetime(key, options = {})
      begin; store(key, ->(item){DateTime.parse(item.to_s)} , options); rescue; raise_type_error(key, "DateTime"); end
    end

    # Checks if the given key is a date or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def date(key, options = {})
      begin; store(key, ->(item){Date.parse(item.to_s)}, options); rescue; raise_type_error(key, "Date"); end
    end

    # Checks if the given key is an array or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def array(key, options = {})
      is_typed?(key, Array) ? store(key, ->(item){item.to_a}, options) : raise_type_error(key, "Array")
    end

    # Checks if the given key is a hash or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def hash(key, options = {})
      is_typed?(key, Hash) ? store(key, ->(item){Hash.try_convert(item)}, options) : raise_type_error(key, "Hash")
    end

    # Checks if the given key is a boolean or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def boolean(key, options = {})
      match?(key, /(true)|(false)/) ? store(key, ->(item){to_boolean(item)}, options) : raise_type_error(key, "Numeric")
    end

    # Checks if the given key is a SSID for a MongoDB object or not.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    def ssid(key, options = {})
      match?(key, /^[0-9a-fA-F]{24}$/) ? store(key, ->(item){BSON::ObjectId.from_string(item.to_s)}, options) : raise_type_error(key, "Moped::BSON::ObjectId")
    end

    # @!endgroup Public_interface

    # @!group Advices

    # Before advice checking for "required", "dependency", and "dependencies" options.
    before calls_to: self.instance_methods(false), exclude_methods: [:initialize, :new, :required, :dependency, :dependencies] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        validator.required(args[0]) if (args[1].has_key?(:required) and args[1][:required] == true)
        if args[1].has_key?(:dependencies)
          validator.dependencies(args[0], args[1][:dependencies])
        elsif args[1].has_key?(:dependency)
          validator.dependency(args[0], args[1][:dependency])
        end
      end
    end

    # After advice checking in numerics if limits are given, and if there are, if they are respected.
    after calls_to: [:integer, :numeric] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        if(args[1].has_key?(:between))
          validator.check_min_value(args[0], args[1][:between][0])
          validator.check_max_value(args[0], args[1][:between][1])
        else
          validator.check_min_value(args[0], args[1][:min]) if(args[1].has_key?(:min))
          validator.check_max_value(args[0], args[1][:max]) if(args[1].has_key?(:max))
        end
      end
    end

    # After advcie for all methods, checking the "in" and "equals" options.
    after calls_to: self.instance_methods(false), exclude_methods: [:initialize, :new, :required, :dependency, :dependencies] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        if(args[1].has_key?(:in))
         validator.in_array?(args[0], args[1][:in])
        elsif(args[1].has_key?(:equals))
          validator.equals_to?(args[0], args[1][:equals])
        end
      end
    end

    # After advice for hashes, checking the "has_keys" and "contains" options.
    after calls_to: [:hash] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        validator.has_keys?(args[0], args[1][:has_keys]) if(args[1].has_key?(:has_keys))
        validator.contains?(args[0], validator.datas[args[0]].values, args[1][:contains]) if(args[1].has_key?(:contains))
      end
    end

    # After advice for arrays, checking the "contains" option.
    after calls_to: [:array] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        validator.contains?(args[0], validator.datas[args[0]], args[1][:contains]) if(args[1].has_key?(:contains))
      end
    end

    after calls_to: [:text] do |joint_point, validator, *args|
      unless !defined?(args[1]) or args[1].nil? or args[1].empty?
        validator.match_regex?(args[0], validator.datas[args[0]], args[1][:regex]) if(args[1].has_key?(:regex))
      end
    end

    # @!endgroup Advices

    # Checks if a required key is present in provided datas.
    # @param [Object] key the key of which check the presence.
    # @raise [ArgumentError] if the key is not present.
    def required(key)
      raise ArgumentError.new("The key #{key} is required and not provided.") unless @datas.has_key?(key)
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
      raise ArgumentError.new("The key #{key} needs the key #{dependency} but it was not provided.") unless @datas.has_key?(dependency)
    end

    # Checks if the value associated with the given key is greater than the given minimum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] min_value the required minimum value.
    # @raise [ArgumentError] if the initial value is strictly lesser than the minimum value.
    def check_min_value(key, min_value)
      raise ArgumentError.new("The key #{key} was supposed to be greater or equal than #{min_value}, the value was #{datas[key]}") unless datas[key].to_i >= min_value.to_i
    end

    # Checks if the value associated with the given key is lesser than the given maximum value.
    # @param [Object]  key the key associated with the value to compare.
    # @param [Numeric] max_value the required maximum value.
    # @raise [ArgumentError] if the initial value is strictly greater than the minimum value.
    def check_max_value(key, max_value)
      raise ArgumentError.new("The key #{key} was supposed to be lesser or equal than #{max_value}, the value was #{datas[key]}") unless datas[key].to_i <= max_value.to_i
    end

    # Checks if the value associated with the given key is included in the given array of values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  values the values in which the initial value should be contained.
    # @raise [ArgumentError] if the initial value is not included in the given possible values.
    def in_array?(key, values)
      raise ArgumentError.new("The key #{key} was supposed to be in [#{values.join(", ")}], the value was #{datas[key]}") unless (values.empty? or values.include?(datas[key]))
    end

    # Checks if the value associated with the given key is equal to the given value.
    # @param [Object] key the key associated with the value to check.
    # @param [Object] value the values with which the initial value should be compared.
    # @raise [ArgumentError] if the initial value is not equal to the given value.
    def equals_to?(key, value)
      raise ArgumentError.new("The key #{key} was supposed to equal than #{value}, the value was #{datas[key]}") unless datas[key] == value
    end

    # Checks if the value associated with the given key has the given required keys.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the keys that the initial Hash typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given keys.
    def has_keys?(key, required_keys)
      raise ArgumentError.new("The key #{key} was supposed to contains keys [#{required_keys.join(", ")}]") if (datas[key].keys & required_keys) != required_keys
    end

    # Checks if the value associated with the given key has the given required values.
    # @param [Object] key the key associated with the value to check.
    # @param [Array]  required_keys the values that the initial Enumerable typed value should contain.
    # @raise [ArgumentError] if the initial value has not each and every one of the given values.
    def contains?(key, values, required_values)
      raise ArgumentError.new("The key #{key} was supposed to contains values [#{required_values.join(", ")}]") if (values & required_values) != required_values
    end

    def match_regex?(key, value, regex)
      regex = Regexp.new(regex) if regex.kind_of?(String)
      raise ArgumentError.new("The key #{key} was supposed to match the regex #{regex} but its value was #{value}") unless regex.match(value)
    end

    private

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

    # Tries to store the associated key in the filtered key, transforming it with the given process.
    # @param [Object] key the key associated with the value to store in the filtered datas.
    # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
    # @param [Hash]   options the options applied to the initial value. Only the option "rename" is checked and executed here.
    def store(key, process, options = {})
      unless (options.has_key?(:extract) and options[:extract] == false)
        if datas.has_key?(key)
          value = ((options.has_key?(:cast) and options[:cast] == false) ? datas[key] : process.call(datas[key]))
          options.has_key?(:rename) ? (@filtered[options[:rename]] = value) : (@filtered[key] = value)
        end
      end
    end

    # Raises a type error with a generic message.
    # @param [Object] key the key associated from the value triggering the error.
    # @param [Class]  type the expected type, not respected by the initial value.
    # @raise [ArgumentError] the chosen type error.
    def raise_type_error(key, type)
      raise ArgumentError.new("The key {key} was supposed to be an instance of #{type}, #{key.class} found.")
    end

    # Transforms a given value in a boolean.
    # @param [Object] value the value to transform into a boolean.
    # @return [Boolean] true if the value was true, 1 or yes, false if not.
    def to_boolean(value)
      ["true", "1", "yes"].include?(value.to_s) ? true : false
    end

  end
end