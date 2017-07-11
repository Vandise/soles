require "soles/version"
require "active_support/core_ext/module/attribute_accessors"

module Soles
  autoload :Application, "soles/application"
  autoload :Configuration, "soles/configuration"
  autoload :Generator, "soles/generator"
  autoload :Controller, "soles/controller"

  mattr_accessor :environment, :configuration, :root
end
