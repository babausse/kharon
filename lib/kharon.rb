# Main module of the application.
# @author Vincent Courtois <courtois.vincent@outlook.com>
module Kharon

  @@use_exceptions = true

  @@processors = {}

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

  # Adds a processor class to the list of processors.
  # @param [Symbol] name the name of the stored processor to retrieve it after. It will be the method you call to process a data with that processor.
  # @param [Class] classname the class object for the processor to be instanciated later.
  def self.add_processor(name, classname)
    @@processors[name] = classname if classname.ancestors.include? Kharon::Processor
  end

  # Removes a processor from the list of available processors.
  # @param [Symbol] name the name (key) of the processor to delete.
  def self.remove_processor(name)
    @@processors.delete(name) if self.has_processor?(name)
  end

  # Getter for the list of processors.
  # @return [Hash] the list of processors currently available.
  def self.processors
    @@processors
  end

  # Checks if a processor currently exists in the system.
  # @param [String] name the name of the processor to check the existence.
  # @return [Boolean] TRUE if the processor exists, FALSE if not.
  def self.has_processor?(name)
    @@processors.keys.include?(name)
  end

  [:Processor, :Validator, :Version, :Errors, :Handlers, :Helpers, :Validate].each { |classname| autoload(classname, "kharon/#{classname.downcase}") }

  Dir[File.join(File.dirname(__FILE__), "kharon/processors/*.rb")].each { |filename| require filename}
end