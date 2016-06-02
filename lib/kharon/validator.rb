module Kharon

  # The validator is the main class of Kharon, it validates a hash given a structure.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Validator

    # @!attribute [r] datas
      # @return [Hash] The datas to filter, they shouldn't be modified to guarantee their integrity.
    attr_reader :datas

    # @!attribute [r] processors
      # @return [Hash] THe processors to process and validate the keys depending on their types.
    attr_reader :processors

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
      @datas      = Hash[datas.map { |k, v| [k.to_sym, v] }]
      @processors = Hash[Kharon.processors.map { |name, classname| [name, classname.new(self)] }]
      @filtered   = Hash.new
      @handler    = Kharon.errors_handler
    end

    # Method used to not directly define the different type validation methods, but instead to look for it in the processors list.
    # @param [String] name the name of the not found method.
    # @param [Array] arguments the arguments passed to the not found method when it's called.
    # @param [Proc] block the block that might have been passed to the not found method when it's called.
    def method_missing(name, *arguments, &block)
      if respond_to? name
        if arguments.count == 1
          processors[name].process(arguments[0])
        elsif arguments.count == 2
          processors[name].process(arguments[0], arguments[1])
        end
      else
        super
      end
    end

    def respond_to?(name, search_private = false)
      processors.keys.include?(name) ? true : super
    end

    # Checks if the given key is a hash or not.
    # This method MUST be defined to override the #hash method with these parameters.
    # @param [Object] key the key about which verify the type.
    # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
    # @example Validates a key so it has to be a hash, and checks if it has some keys.
    #   @validator.date(:a_hash, has_keys: [:first, :second])
    def hash(key, options = {})
      processors[:hash].process(key, options)
    end

  end
end