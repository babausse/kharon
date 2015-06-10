require "kharon/version"
require "kharon/validator"
require "kharon/helpers/validate"
require "kharon/configuration"

require "kharon/errors/validation"

require "kharon/handlers/exceptions"
require "kharon/handlers/messages"

module Kharon

  # Configuration method used to tell the module if it uses exceptions or stores error messages.
  # @param [Boolean] use TRUE if you want to use exceptions, FALSE else.
  def self.use_exceptions(use = true)
    Kharon::Configuration.instance.use_exceptions(use)
  end

  # Returns the current error handler, defined by if you use exceptions or not.
  # @return [Object] an instance of Kharon::Handlers::Exceptions if you use exceptions, an instance of Kharon::Handlers::Messages else.
  def self.errors_handler
    Kharon::Configuration.instance.uses_exceptions? ? Kharon::Handlers::Exceptions.instance : Kharon::Handlers::Messages.new
  end
end