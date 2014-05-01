# Charon the boatkeeper

## What is charon ?

Charon was, in the greek mythology, the ferryman to cross the Styx river. He decided who passed, and who didn't pass, and it's exactly what this gem does. It validates a hash given criterias about its keys, and let the execution of the program continue if the requirements are fulfilled, stop it if not.

## Installation

It's a gem, you know how to install a gem, or you should if you're using it in a ruby application. Okay, let's consider you don't, just type :

```
gem install charon
```

And... That's it ! Now it's installed and you can learn how to properly use it !

## How to use the gem

First, you need to include the gem to your application. Usually you can just do :

```ruby
require "charon"
```

### The validator

The Charon::Validator class is the main class of this gem, it offers an interface to validate hashes and see if they fulfill requirements. first, you have to create an instance of the validator :

```ruby
validator = Charon::Validator.new(hash_to_validate)
```

Now your validator knows which hash it has to validate, now you can do :

```ruby
# Sees if the "required_integer_key" key is present, and an integer
validator.integer("required_integer_key", required: true)
```

All the functions are listed in the full documentation below.

### The helper

This gem was firstly designed to be used as a helper for Sinatra applications, so it contains another useful module : Charon::Helpers. To use it in your Sinatra application, just type this in the controllers where you want it included :

```ruby
helpers Charon::Helpers
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

#### mongoid

This method is only useful if you use Mongoid or an ORM linking MongoDB to your application. It validates the data associated with the key only if it's a string formatted as a MongoDB unique identifier.

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