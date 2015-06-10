require "spec_helper"

describe "Errors::Validation" do
  let!(:error_hash) { {type: "type", key: "custom key"} }

  it "correctly stores the error hash" do
    expect(Kharon::Errors::Validation.new(error_hash).error_hash).to eq(error_hash)
  end

  it "correctly return the JSON equivalent of the error hash as message" do
    expect(Kharon::Errors::Validation.new(error_hash).message).to eq(JSON.generate(error_hash))
  end
end