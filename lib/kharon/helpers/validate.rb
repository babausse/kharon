module Kharon
  module Helpers

    # Validates the datas passed as parameter with a Phenix::Validator and the given instructions.
    # @param  [Hash] datas the parameters to validate with the given instructions.
    # @param  [Proc] block the instructions to apply on the validator.
    # @return [Hash] the validated and filtered datas.
    def validate(datas, &block)
      validator = Kharon::Factory.validator(datas)
      validator.instance_eval(&block)
      return validator.filtered
    end

  end
end