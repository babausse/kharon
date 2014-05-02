require 'rack/test'
require 'moped'
require './lib/validator_factory.rb'

describe "Kharon::Factory" do

  context "validator" do
    it "produces a Kharon::Validator when exceptions are wanted" do
      Kharon::Factory.use_exceptions(true)
      expect(Kharon::Factory.validator({key: "value"})).to be_a(Kharon::Validator)
    end

    it "produces a Kharon::CoolValidator when exceptions are not wanted" do
      Kharon::Factory.use_exceptions(false)
      expect(Kharon::Factory.validator({key: "value"})).to be_a(Kharon::CoolValidator)
    end
  end

  context "configure" do
    it "correctly configures the module to use exceptions" do
      Kharon::Factory.configure do |configuration|
        configuration.use_exceptions(true)
      end
      expect(Kharon::Factory.uses_exceptions?).to be(true)
    end

    it "correctly configures the module to not use exceptions" do
      Kharon::Factory.configure do |configuration|
        configuration.use_exceptions(false)
      end
      expect(Kharon::Factory.uses_exceptions?).to be(false)
    end
  end

end