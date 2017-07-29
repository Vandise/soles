require "soles/version"
require "active_support/core_ext/module/attribute_accessors"

module Soles
  autoload :Application, "soles/application"
  autoload :Configuration, "soles/configuration"
  autoload :Generator, "soles/generator"
  autoload :Controller, "soles/controller"

  mattr_accessor :environment, :configuration, :root, :logger

  def self.on_exit(&block)
    @on_exit_blocks ||= Concurrent::Array.new
    @on_exit_blocks << block
  end

  def self.shutdown
    @on_exit_blocks.each(&:call) if @on_exit_blocks
  end
end
