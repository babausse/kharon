module Kharon
  # Module to include to use the #validate method in your own classes. It offers an easier way to validate datas than creating the validator from scratch.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  module Validate
    # Validates the datas passed as parameter with a Kharon::Validator and the given instructions.
    # @param  [Hash] datas the parameters to validate with the given instructions.
    # @param  [Proc] block the instructions to apply on the validator.
    # @return [Hash] the validated and filtered datas.
    def validate(datas, &block)
      begin
        validator = Kharon::Validator.new(datas)
        validator.instance_eval(&block)
        return validator.filtered
      rescue Kharon::Errors::Validation => exception
        raise exception
      rescue Exception => exception
        raise Kharon::Errors::Validation.new({type: "standard", exception: exception.class.to_s, backtrace: exception.backtrace, message: exception.message})
      end
    end
  end
end