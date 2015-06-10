require "spec_helper"

describe "Kharon" do
  it "Can not use exceptions" do
    Kharon.use_exceptions(false)
    expect(Kharon.errors_handler).to be_a(Kharon::Handlers::Messages)
  end

  it "Can use exceptions" do
    Kharon.use_exceptions(true)
    expect(Kharon.errors_handler).to be_a(Kharon::Handlers::Exceptions)
  end
end