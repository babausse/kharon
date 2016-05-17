require 'spec_helper'

class DummyClass
  include Kharon::Validate
end

describe "Validate" do

  let(:dummy) { DummyClass.new }

  context "validate" do
    it "correctly validates a hash" do
      expect(dummy.validate({key: "1"}) { integer :key, required: true }).to eq({key: 1})
    end

    it "fails when an error is raised by validation" do
      expect(->{dummy.validate({key: "something"}) {integer :key}}).to raise_error(Kharon::Errors::Validation)
    end
  end
end