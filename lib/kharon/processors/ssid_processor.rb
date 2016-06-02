module Kharon
  module Processors

    # Processor to validate MongoDB SSID. It only has the default options.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class SSIDProcessor < Kharon::Processor

      Kharon.add_processor(:ssid, Kharon::Processors::SSIDProcessor)

      # Checks if the given key is a not-empty string or not.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a string, and seems like and email address (not sure of the regular expression though).
      #   @validator.text(:an_email, regex: "[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]{2-4}")
      def process(key, options = {})
        before_all(key, options)
        match?(key, /^[0-9a-fA-F]{24}$/) ? store(key, ->(item){BSON::ObjectId.from_string(item.to_s)}, options) : raise_type_error(key, "Moped::BSON::ObjectId")
      end
    end
  end
end