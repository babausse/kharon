module Kharon
  # This module contains the class representing custom errors raised whithin the application.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  module Errors
    autoload(:Validation, File.join(File.dirname(__FILE__), "errors/validation"))
  end
end