require 'spec_helper'
require './lib/validator.rb'

shared_examples "options" do |process|
  context ":rename" do
    it "correctly renames a key when the value is valid" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, rename: :another_name)
      expect(validator.filtered[:another_name]).to eq(valid_filtered[valid_datas.keys.first])
    end

    it "correctly doesn't rename a key when the value is invalid" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.send(process, invalid_datas.keys.first, rename: :another_name)}).to raise_error(ArgumentError)
    end
  end

  context ":dependency" do
    it "succeeds when a dependency is given as a key and respected" do
      validator = Kharon::Validator.new(valid_datas.merge({dep: "anything"}))
      validator.send(process, valid_datas.keys.first, dependency: :dep)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when a dependency is not respected" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, valid_datas.keys.first, dependency: :another_key_not_existing)}).to raise_error(ArgumentError)
    end
  end

  context ":dependencies" do
    it "succeeds when dependencies are given as an array and respected" do
      validator = Kharon::Validator.new(valid_datas.merge({dep1: "something", dep2: "something else"}))
      validator.send(process, valid_datas.keys.first, dependencies: [:dep1, :dep2])
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when one of the dependencies is not respected" do
      validator = Kharon::Validator.new(valid_datas.merge({dep1: "anything"}))
      expect(->{validator.send(process, valid_datas.keys.first, dependencies: [:dep1, :dep2])}).to raise_error(ArgumentError)
    end
  end

  context ":required" do
    it "succeeds when a not required key is not given, but filters nothing" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, :not_required_key)
      expect(validator.filtered).to be_empty
    end

    it "suceeds when a key has a required option to false, and is not given, but filters nothing" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, :not_in_hash, required: false)
      expect(validator.filtered).to be_empty
    end

    it "fails when a required key is not given" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, :not_in_hash, required: true)}).to raise_error(ArgumentError)
    end
  end

  context ":in" do
    it "succeeds when the value is effectively in the possible values" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :in => [valid_datas[valid_datas.keys.first], "another random data"])
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds if there are no values" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :in => [])
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails if the value is not in the possible values" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, valid_datas.keys.first, :in => ["anything but the value", "another impossible thing"])}).to raise_error(ArgumentError)
    end
  end

  context ":equals" do
    it "succeeds when the value is equal to the given value" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :equals => valid_datas[valid_datas.keys.first])
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails if the value is not equal to the given value" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, valid_datas.keys.first, :equals => "anything but the given value")}).to raise_error(ArgumentError)
    end
  end

  context ":extract" do
    it "etracts the data when given at true" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :extract => false)
      expect(validator.filtered).to eq({})
    end

    it "doesn't extract the data when given at false" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :extract => true)
      expect(validator.filtered).to eq(valid_filtered)
    end
  end

  context ":cast" do
    it "casts the data when given at true" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :cast => true)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "doesn't cast the data when given at false" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, valid_datas.keys.first, :cast => false)
      expect(validator.filtered).to eq(valid_datas)
    end
  end
end

shared_examples "type checker" do |type, process|
  it "succeeds when given an instance of #{type}" do
    validator = Kharon::Validator.new(valid_datas)
    validator.send(process, valid_datas.keys.first)
    expect(validator.filtered).to eq(valid_filtered)
  end

  it "fails when given something else than an instance of #{type}" do
    validator = Kharon::Validator.new(invalid_datas)
    expect(->{validator.send(process, invalid_datas.keys.first)}).to raise_error(ArgumentError)
  end
end

shared_examples "min/max checker" do |process, key, transformation|
  let(:value)     { valid_datas[key].send(transformation) }
  let(:validator) { Kharon::Validator.new(valid_datas) }

  context ":min" do
    it "succeeds when a min option is given, and the value is strictly greater than it" do
      validator.send(process, key, {min: value-1})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds when a min option is given, and the value is equal to it" do
      validator.send(process, key, {min: value})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when a min option is given, but not respected" do
      expect(->{validator.send(process, key, {min: value+1})}).to raise_error(ArgumentError)
    end
  end

  context ":max" do
    it "succeeds when a max option is given, and the value is strictly lesser than it" do
      validator.send(process, key, {max: value+1})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds when a max option is given, and the value is equal to it" do
      validator.send(process, key, {max: value})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when a max option is given, but not respected" do
      expect(->{validator.send(process, key, {max: value-1})}).to raise_error(ArgumentError)
    end
  end

  context ":between" do

    it "succeeds when a between option is given, and respected" do
      validator.send(process, key, {between: [value-1, value+1]})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when a max between option is given, but the value is strictly lesser" do
      expect(->{validator.send(process, key, {between: [value+1, value+2]})}).to raise_error(ArgumentError)
    end

    it "fails when a max between option is given, but the value is strictly greater" do
      expect(->{validator.send(process, key, {between: [value-2, value-1]})}).to raise_error(ArgumentError)
    end

    it "fails when a max between option is given, but the value is equal to the inferior limit" do
      validator.send(process, key, {between: [value, value+1]})
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when a max between option is given, but the value is equal to the superio limit" do
      validator.send(process, key, {between: [value-1, value]})
      expect(validator.filtered).to eq(valid_filtered)
    end
  end
end

shared_examples "contains option" do |process, key|
  context ":contains" do
    it "succeeds if all values are contained" do
      validator = Kharon::Validator.new(valid_datas)
      validator.send(process, key, contains: ["val1", "val2"])
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails if only some values are contained" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, key, contains: ["val1", "val3"])}).to raise_error(ArgumentError)
    end

    it "fails if none of the values are contained" do
      validator = Kharon::Validator.new(valid_datas)
      expect(->{validator.send(process, key, contains: ["val3", "val4"])}).to raise_error(ArgumentError)
    end
  end
end

describe "Validator" do
  context "integer" do
    let(:valid_datas)    { {is_an_integer: "1000"} }
    let(:valid_filtered) { {is_an_integer: 1000} }
    let(:invalid_datas)  { {is_not_an_integer: "something else"} }

    it "succeeds when given an integer" do
      validator = Kharon::Validator.new(valid_datas)
      validator.integer(:is_an_integer)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when given a float" do
      validator = Kharon::Validator.new({is_not_an_integer: 1000.5})
      expect(->{validator.integer(:is_not_an_integer)}).to raise_error(ArgumentError)
    end

    it "fails when not given a numeric" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.integer(:is_not_an_integer)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :integer
      include_examples "min/max checker", :integer, :is_an_integer, :to_i
    end
  end

  context "numeric" do
    let(:valid_datas)    { {is_a_double: "1000.5"} }
    let(:valid_filtered) { {is_a_double: 1000.5} }
    let(:invalid_datas)  { {is_not_a_numeric: "something else"} }

    it "succeeds when given an integer" do
      validator = Kharon::Validator.new({is_an_integer: "1000"})
      validator.numeric(:is_an_integer)
      expect(validator.filtered).to eq({is_an_integer: 1000})
    end

    it "succeeds when given an decimal number with a dot" do
      validator = Kharon::Validator.new(valid_datas)
      validator.numeric(:is_a_double)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds when given an decimal number with a comma" do
      validator = Kharon::Validator.new({is_a_double: "1000,5"})
      validator.numeric(:is_a_double)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when not given a numeric" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.integer(:is_not_a_numeric)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :numeric
      include_examples "min/max checker", :numeric, :is_a_double, :to_f
    end
  end

  context "text" do
    let(:valid_datas)    { {is_a_string: "something"} }
    let(:valid_filtered) { {is_a_string: "something"} }
    let(:invalid_datas)  { {is_not_a_string: 1000} }

    include_examples "type checker", "String", :text

    context "options" do
      include_examples "options", :text

      context ":regex" do
        it "succeeds when the regular expression is respected" do
          validator = Kharon::Validator.new(valid_datas)
          validator.text(:is_a_string, regex: "some")
          expect(validator.filtered).to eq(valid_filtered)
        end

        it "fails when the regular expression is not respected" do
          validator = Kharon::Validator.new(valid_datas)
          expect(->{validator.text(:is_a_string, regex: "anything else")}).to raise_error(ArgumentError)
        end
      end
    end
  end

  context "datetime" do
    let(:date_time)      { DateTime.new }
    let(:valid_datas)    { {is_a_datetime: date_time.to_s} }
    let(:valid_filtered) { {is_a_datetime: date_time} }
    let(:invalid_datas)  { {is_not_a_datetime: "something else"} }

    it "succeeds when given a valid datetime as a string" do
      validator = Kharon::Validator.new(valid_datas)
      validator.datetime(:is_a_datetime)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds when given a valid datetime as a DateTime Object" do
      validator = Kharon::Validator.new(valid_filtered)
      validator.datetime(:is_a_datetime)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when given something else than a valid datetime" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.datetime(:is_not_a_datetime)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :datetime
    end
  end

  context "date" do
    let(:date)           { Date.new }
    let(:valid_datas)    { {is_a_date: date.to_s} }
    let(:valid_filtered) { {is_a_date: date} }
    let(:invalid_datas)  { {is_not_a_date: "something else"} }

    it "succeeds when given a valid date as a string" do
      validator = Kharon::Validator.new(valid_datas)
      validator.date(:is_a_date)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "succeeds when given a valid date as a Date Object" do
      validator = Kharon::Validator.new(valid_filtered)
      validator.date(:is_a_date)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when given something else than a valid date" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.date(:is_not_a_date)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :date
    end
  end

  context "array" do
    let(:valid_datas)    { {is_an_array: ["val1", "val2"]} }
    let(:valid_filtered) { {is_an_array: ["val1", "val2"]} }
    let(:invalid_datas)  { {is_not_an_array: 1000} }

    include_examples "type checker", "Array", :array

    context "options" do
      include_examples "options", :array
      include_examples "contains option", :array, :is_an_array
    end
  end

  context "hash" do
    let(:valid_datas)    { {is_a_hash: {key1: "val1", key2: "val2"}} }
    let(:valid_filtered) { {is_a_hash: {key1: "val1", key2: "val2"}} }
    let(:invalid_datas)  { {is_not_a_hash: 1000} }

    include_examples "type checker", "Hash", :hash

    context "options" do
      include_examples "options", :hash
      include_examples "contains option", :hash, :is_a_hash

      context ":has_keys" do
        it "succeeds if all keys are contained in the hash" do
          validator = Kharon::Validator.new(valid_datas)
          validator.hash(:is_a_hash, has_keys: [:key1, :key2])
          expect(validator.filtered).to eq(valid_filtered)
        end

        it "fails if not all keys are given in the hash" do
          validator = Kharon::Validator.new(valid_datas)
          expect(->{validator.hash(:is_a_hash, has_keys: [:key1, :key3])}).to raise_error(ArgumentError)
        end

        it "fails if no keys are contained in the hash" do
          validator = Kharon::Validator.new(valid_datas)
          expect(->{validator.hash(:is_a_hash, has_keys: [:key3, :key4])}).to raise_error(ArgumentError)
        end
      end
    end
  end

  context "boolean" do
    let(:valid_datas)    { {is_a_boolean: "true"} }
    let(:valid_filtered) { {is_a_boolean: true} }
    let(:invalid_datas)  { {is_not_a_boolean: "anything else"} }

    it "succeeds when given a boolean" do
      validator = Kharon::Validator.new(valid_datas)
      validator.boolean(:is_a_boolean)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when not given a boolean" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.boolean(:is_not_a_boolean)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :boolean
    end
  end

  context "ssid" do
    let(:valid_ssid)     { BSON::ObjectId.new }
    let(:valid_datas)    { {is_a_ssid: valid_ssid.to_s} }
    let(:valid_filtered) { {is_a_ssid: valid_ssid} }
    let(:invalid_datas)  { {is_not_a_ssid: "anything else"} }

    it "succeeds when given a valid SSID" do
      validator = Kharon::Validator.new(valid_datas)
      validator.ssid(:is_a_ssid)
      expect(validator.filtered).to eq(valid_filtered)
    end

    it "fails when not given a SSID" do
      validator = Kharon::Validator.new(invalid_datas)
      expect(->{validator.ssid(:is_not_a_ssid)}).to raise_error(ArgumentError)
    end

    context "options" do
      include_examples "options", :ssid
    end
  end

end