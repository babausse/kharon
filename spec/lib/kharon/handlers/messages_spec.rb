require "spec_helper"

describe "Handlers::Messages" do
  it "can correctly store several errors" do
    handler = Kharon::Handlers::Messages.new
    handler.report_error({key: "value1"})
    handler.report_error({key: "value2"})

    expect(handler.errors.count).to be(2)
  end
end