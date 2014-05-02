require 'spec_helper'

describe "CoolValidator" do
  context "handling errors" do

    before do
      @validator = Kharon::CoolValidator.new({key: "value"})
    end

    it "doesn't raise an exception when an error occurs" do
      expect(->{@validator.any(:another, required: true)}).to_not raise_error
    end

    it "has an error when an error has occured" do
      @validator.any(:another, required: true)
      expect(@validator.has_errors?).to be(true)
    end

    it "doesn't have an error when none has occured" do
      @validator.any(:key, required: true)
      expect(@validator.has_errors?).to be(false)
    end
  end
end