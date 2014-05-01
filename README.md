# Kharon the boatkeeper

## What is charon ?

Charon (or Khàrôn in ancient greek) was, in the greek mythology, the ferryman to cross the Styx river. He decided who passed, and who didn't pass, and it's exactly what this gem does.

It validates the datas in a hash given criterias about its keys, and let the execution of the program continue if the requirements are fulfilled, stop it if not. The datas in the hash are supposed to be strings, Kharon being designed to validate datas coming in a web application from the outside (tipically, datas passed in a querystring or a POST body).

## Contact me

For any question or advice, contact me at vincent.courtois@mycar-innovations.com. I'll answer as soon as possible, and thank you by advance for giving me some of your time.

## Requirements

You'll just need Ruby 1.9.3 at least to make it work.

## Installation

### From Rubygems.org

It's a gem, you know how to install a gem, or you should if you're using it in a ruby application. Okay, let's consider you don't, just type :

```
gem install kharon
```

And... That's it ! Now it's installed and you can learn how to properly use it !

### From sources

Clone this repository whenether you want, go inside, then type the following command :

```
gem install kharon-0.1.0
```

The gem will be installed on your system, from then on you can use it inside your applications.

## Run tests

This gem is tested using RSpec, to run the tests, clone the repository, go in, then type :

```
% bundle install
% bundle exec rspec --format documentation --color
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
# Sees if the "required_integer_key" key is present, and an integer
validator.integer("required_integer_key", required: true)
```

All the functions are listed in the full documentation below.

### The helper

This gem was firstly designed to be used as a helper for Sinatra applications, so it contains another useful module : Kharon::Helpers. To use it in your Sinatra application, just type this in the controllers where you want it included :

```ruby
helpers Kharon::Helpers
```

From there, you can type it in any of the routes of this controller :

```ruby
validate(hash_to_validate) do
  integer "required_integer_key", required: true
end
```

This code is strictly equivalent to the one presented above, it uses the block syntax of ruby to give you a nice and fancy way to validate your datas !

## Full documentation

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

This method will validate any value associated to the given key, it's useful if you just want to pass options like :required or :dependency

#### :mongoid

This method is only useful if you use Mongoid or an ORM linking MongoDB to your application. It validates the data associated with the key only if it's a string formatted as a MongoDB unique identifier.

#### :in_array

This method shouldn't be used. Really. It validates the key only if the associated data is in the given array, *not* checking its type. It's recommended to use a type checking method and the ":in" option instead, safer. I shouldn't even make documentation about it. Forget this section, the :in_array method doesn't exist.

### Options

#### :required

This option can be given to say that a key has to be in the hash for it to be validated. It can be used with all methods.

#### :dependency

This options say that this key needs another key to be present for the hash to be validated. It can be used with all methods.

#### :dependencies

This options is used to pass several dependecies at once, as an array of keys. See :dependency option for details. It can be used with all methods.
Note: the :dependencies option *overrides* the :dependency option if both are given.

#### :in

This option is used to give an array of possible values for the given key. If the value of the key is not in thius array, the validator fails. It can be used with all methods.

#### :equals

For the value of a given key in the hash to be equal to the given value. It can be used with all methods.

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

The value of round must be a boolean to work properly. If given at TRUE, floor the decimal number identified by this key. This option can be used with the :numeric method.

#### :ceil

The value of round must be a boolean to work properly. If given at TRUE, ceil the decimal number identified by this key. This option can be used with the :numeric method.

#### :round

The value of round must be an integer to work properly. If given, round the decimal number keeping the given number of digits after the comma. This option can be used with the :numeric method.

#### :regex

The value of this option must be passed as a string. If given as a string, verity that the associated string matches the given regular expression. This option can be used with the :text method.

### Example god damn it !

Here is an example to demonstrate the power of Kharon (made with the helper) :

```ruby
@validated = validate(parameters) do
  numeric  "price", required: true, min: 0
  datetime "added"
  text     "added_by", dependency: "added"
end
```

This example could validate the datas coming in the application in a search engine route for products in a supermarket.