require "soles/version"

module Soles
  autoload :Application, "soles/application"
  autoload :Configuration, "soles/configuration"

  def self.mattr_accessor(*names)
    names.each do |name|
      define_method("#{name}") do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |arg|
        instance_variable_set("@#{name}", arg)
      end
      module_function :"#{name}=", :"#{name}"
    end
  end

  mattr_accessor :environment, :configuration, :root
end
