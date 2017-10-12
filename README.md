# Kharon the boatkeeper

## What is kharon ?

Charon (or Khàrôn in ancient greek) was, in the greek mythology, the ferryman to cross the Styx river. He decided who passed, and who didn't pass, and it's exactly what this gem does.

It validates the datas in a hash given criterias about its keys, and let the execution of the program continue if the requirements are fulfilled, stop it if not. The datas in the hash are supposed to be strings, Kharon being designed to validate datas coming in a web application from the outside (tipically, datas passed in a querystring or a POST body).

## Contact me

For any question or advice, contact me at courtois.vincent@outlook.com. I'll answer as soon as possible, and thank you by advance for giving me some of your time.

## Requirements

You'll just need Ruby 1.9.3 at least to make it work.

## Installation

### From Rubygems.org

It's a gem, you know how to install a gem, or you should if you're using it in a ruby application. Okay, let's consider you don't, just type :

```
gem install kharon
```

And... That's it ! Now it's installed and you can learn how to properly use it !

### With bundler

Add it to your Gemfile :

```
gem "kharon", "<version>"
```

<version> being the version of the gem you want to install.

then run the following command :

```
bundle install
```

### From sources

Clone this repository whenether you want, go inside, then type the following command :

```
gem install dist/kharon-<version>
```

<version> being the version of the gem you want to install.

The gem will be installed on your system, from then on you can use it inside your applications.

## Configuration

### Use exceptions or not use exceptions, that is the question

In some cases you could want to not raise an exception each and every time an error occurs in the validation process. To stop using exceptions, just type :

```
Kharon.use_exceptions(false)
```

and put it somewhere in your application, typically in a /config/initializers/kharon.rb file for a rails application.

You can put back the original behaviour by calling it and passing true as the first parameter, or no parameter, instead of false.

## Run tests

This gem is tested using RSpec, to run the tests, clone the repository, go in, then type :

```
% bundle install
% bundle exec rspec
```

## How to use the gem

First, you need to include the gem to your application. Usually you can just do :

```ruby
require "kharon"
```

### The validator

The Kharon::Validator class is the main class of this gem, it offers an interface to validate hashes and see if they fulfill requirements. first, you have to create an instance of the validator :

```ruby
validator = Kharon::Validator.new(hash_to_validate)
```

Now your validator knows which hash it has to validate, now you can do :

```ruby
# Sees if the :required_integer_key key is present, and an integer
validator.integer(:required_integer_key, required: true)
```

Note: all keys are converted in symbols, and you must use symbols in all method calls on a validator.

All the functions are listed in the full documentation below.

### The helper

This gem was firstly designed to be used in controllers for Rails or Sinatra applications. To use it easily in such a context, include the Kharon::Validate module and the validate method, for example for a Rails controller :

```ruby
class DummyController < ApplicationController
  include Kharon::Validate

  def show
    validate(params) do
      mongoid :id
    end
  end
end
```

This code is strictly equivalent to the one presented above, it uses the block syntax of ruby to give you a nice and fancy way to validate your datas !

## Full documentation

### Generated documentation

Generated documentation can be displayed by displaying the doc/index.html file in a browser.

### Methods

Methods signification are pretty straight-forward as it validates type :

- :integer
- :numeric
- :text
- :any
- :datetime
- :date
- :array
- :hash
- :boolean
- :mongoid

#### :any

This method will validate any value associated to the given key, it's useful if you just want to pass options like :required or :dependency without checking for a particular type.

#### :mongoid

This method is only useful if you use Mongoid or an ORM linking MongoDB to your application. It validates the data associated with the key only if it's a string formatted as a MongoDB unique identifier.

### Options

#### :required

This option can be given to say that a key has to be in the hash for it to be validated. It can be used with all methods.

#### :dependency

This option says that this key needs another key to be present for the hash to be validated. It can be used with all methods.

#### :dependencies

This options is used to pass several dependecies at once, as an array of keys. See :dependency option for details. It can be used with all methods.
Note: the :dependencies option *overrides* the :dependency option if both are given.

#### :in

This option is used to give an array of possible values for the given key. If the value of the key is not in thius array, the validator fails. It can be used with all methods.

#### :equals

this method compares the value of the given key in the hash to be equal to the given value. It can be used with all methods.

#### :equals_key

this method compares the value of the given key in the hash to be equal to the value associated with the compared key in the same hash. It can be used with all methods.

#### :min

This option allows you to specify a non-strict minimum limit for the value associated with the given key. The value has to be passed as an integer. It can be used with :numeric or :integer methods.

#### :max

This option allows you to specify a non-strict maximum limit for the value associated with the given key. The value has to be passed as an integer. It can be used with :numeric or :integer methods.

#### :between

This option gives an interval in which the value of the given key must be to fulfill the requirement. The value has to be passed as an array of two integers, first the minimum, then the maximum. It can be used with :numeric or :integer methods.
Note: the :between option *overrides* the :min *and* :max options if several are given.

#### :contains

This option is used to see if an array or a hash situated at the given key contains some values. The values must be passed as an array. This option can be used with the :hash and :array methods.

#### :has_keys

This option is used to see if a hash situated at the given key contains some keys. The values must be passed as an array. This option can be used with the :hash and :array methods.

#### :cast

This option, if not given, is set to TRUE. If given at false, doesn't type cast the result of the validation so you keep the original string and just check its type. It can be used with all methods.

#### :extract

This option, if not given, is set to TRUE. If given at false, doesn't extract the given key, just validate its type. It can be used with all methods.

#### :floor

If given and TRUE, floors the decimal number identified by this key. This option can be used with the :numeric method.

#### :ceil

If given and TRUE, ceils the decimal number identified by this key. This option can be used with the :numeric method.

#### :round

If given, as an integer, rounds the decimal number keeping the given number of digits after the comma ; if given as a boolean, rounds the decimal number, leaving no decimal digits. This option can be used with the :numeric method.

#### :regex

The value of this option must be passed as a string. If given as a string, verity that the associated string matches the given regular expression. This option can be used with the :text method.

#### :at_most

The value of this option must be passed as a box. When given, this option indicates the maximum value for the associated box. The associated box can't cross any of these coordinates.

#### :at_least

The value of this option must be passed as a box. When given, this option indicates the minimum value for the associated box. The associated box can't be tinier than the given box.

### Errors formats

In Kharon, errors are formatted in a particular way. Each error contains a hash (or associative array) describing its type, and giving special caracteristics if necessary.

#### standard error

This error is the one raised when an error occurs that has nothing to deal with the validation itself. It's mainly raised when a ruby errors occurs. It's formatted as followed :

- type: always has the value "standard"
- exception: the type of the exception
- message: the formatted message for the exception
- backtrace: the whole backtrace for the exception

#### type error

The most common error. It's raised when a type is expected for a key, and the given type for this key is different. It's formatted as followed :

- type : always has the value "type"
- key : the key concerned by the error in the validated hash
- supposed : the type of which the value associated with the key is supposed to be
- given : the type effectively given for the value associated with the key

#### required error

This error is raised when a key was required in the validated hash, but was not given. It's formatted as followed :

- type : always has the value "required"
- key : the required, but not provided, key

#### dependency error

This error is raised when a dependency was needed, but not provided, for a key. It's formatted as followed :

- type : always has the value "dependency"
- key : the key needing another key to properly work
- dependency : the needed, but not provided, dependency

#### min/max error

This error is raised when a key must have a minimum or maximum value, but the provided value is below the minimum or above the maximum. It's formatted as followed :

- type : has either "min" or "max" value
- supposed : the maximum or minimum value the provided value mustn't exceed
- key : the key concerned byt the error
- value : the value not respecting the minimum or maximum asked

#### in_array error

This error is raised when the value associated with a key should belong to a range of values, and doesn't. It's formatted as followed :

- type : always has the "array.in" value
- key : the key concerned byt the error
- supposed : the range of values in which the value associated with the key should belong to
- value : the value provided with the key

#### equals error

This error is raised when the value associated to a key was expected to be equal to a value, but wasn't. It's formatted as followed :

- type : always has the "equals" value
- key : the key concerned byt the error
- supposed : the value the key was supposed to have
- value : the effective value associated to the key

#### contains keys error

This error is raised when a key, which type is a hash, doesn't contain the provided values as keys. It's formatted as followed :

- type : always has the "contains.keys" value
- key : the key concerned byt the error
- required : the keys that must be contained in the value hash
- value : the hash provided with the validated key

#### contains values error

This error is raised when a key, which type is an array or a hash, doesn't contain the provided values. It's formatted as followed :

- type : always has the "contains.values" value
- key : the key concerned byt the error
- required : the values that must be contained in the value hash
- value : the hash provided with the validated key

#### regex error

This error is raised when a value was expecting to respect a regular expression, but didn't. It's formatted as followed :

- type : always has the "regex" value
- key : the key concerned by the error
- regex : the regular expression expected to be respected
- value : the effective value not respecting the regular expression

#### box format error

This error is raised when a geographic box is not well formatted. It's formatted as followed :

- type : always has the "box.format" value
- key : the key concerned by the error
- value : the effective value of the box, not respecting the format of a box

#### box containment error

This error is raised when a given key, as a box, is not contained in the box it should be (with the :at_most and :at_least options). It's formatted as followed :

- type : always has the "box.containment" value
- key : the key concerned by the error
- container : the box whithin which the contained box must be
- contained : the box that must be contained in the container

### Does it work ?

Yes, it works, unit tests results can be found here : {file:doc/results.html results of unit tests}
