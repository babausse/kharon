require 'bundler/setup'
Bundler.setup

# Sets the environment variable to test before loading all the files.
ENV['RACK_ENV'] = 'test'

require "bson"
require "json"
require "kharon"