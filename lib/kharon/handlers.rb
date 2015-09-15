module Kharon
  # This module contains the error handlers available in the application.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  module Handlers
    autoload(:Exceptions, File.join(File.dirname(__FILE__), "handlers/exceptions"))
    autoload(:Messages, File.join(File.dirname(__FILE__), "handlers/messages"))
  end
end