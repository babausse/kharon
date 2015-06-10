require "spec_helper"

describe "Handlers::Exceptions" do
  it "always returns the same instance" do
    expect(Kharon::Handlers::Exceptions.instance).to be(Kharon::Handlers::Exceptions.instance)
  end

  context "#report_error" do
    it "raises an error of the right type" do
      expect{Kharon::Handlers::Exceptions.instance.report_error({})}.to raise_error(Kharon::Errors::Validation)
    end
  end
end