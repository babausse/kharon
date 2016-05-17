# Main module of the application.
# @author Vincent Courtois <courtois.vincent@outlook.com>
module Kharon

  [:Validator, :Version, :Errors, :Handlers, :Helpers, :Validate].each { |classname| autoload(classname, "kharon/#{classname.downcase}") }

  @@use_exceptions = true

  # Configuration method used to tell the module if it uses exceptions or stores error messages.
  # @param [Boolean] use TRUE if you want to use exceptions, FALSE else.
  def self.use_exceptions(use = true)
    @@use_exceptions = use
  end

  # Returns the current error handler, defined by if you use exceptions or not.
  # @return [Object] an instance of Kharon::Handlers::Exceptions if you use exceptions, an instance of Kharon::Handlers::Messages else.
  def self.errors_handler
    @@use_exceptions ? Kharon::Handlers::Exceptions.instance : Kharon::Handlers::Messages.new
  end
end