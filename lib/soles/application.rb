require 'active_support/dependencies'
require 'active_support/descendants_tracker'
require 'logger'

module Soles
  class Application
    def initialize(base_directory, options = {})
      Soles.root = base_directory
      parse_environment!(options)
      Soles.configuration = setup_configuration(options)
      Soles.logger = Logger.new(File.join(Soles.root, "log", "soles.#{Soles.environment}.log"))
      setup_autoloader!
      load_environment!
      yield Soles.configuration if block_given?
      load_initializers!
      load_commands!
    end
    
    def root
      Soles.root
    end

    def configuration
      Soles.configuration
    end

    private

    def load_commands!
      Dir.glob(File.join(Soles.root, "app", "controllers", "**", "*.rb")).sort.each do |file|
        require file
      end

      Soles::Controller.descendants.each do |klass|
        klass.register_in(::Soles::Commands) if defined?(::Soles::Commands)
      end
    end

    def setup_configuration(options)
      default_config_path = File.join(Soles.root, "config", "configs", "**", "*.yml")
      config_path = options[:config_path] || default_config_path
      config_files = options[:config_files] || Dir.glob(config_path)
      @configuration ||= Configuration.new(Soles.environment, config_files)
    end
    
    def parse_environment!(options)
      Soles.environment = options[:environment] || ENV[options.fetch(:environment_key, 'SOLES_ENV')] || "development"
    end

    def load_environment!
      file = File.join(Soles.root, "config", "environments", Soles.environment, ".rb")
      if File.exists?(file)
        File.open(file) {|f| eval f.read, binding, file }      # rubocop:disable Lint/Eval
      end
    end

    def load_initializers!
      Dir.glob(File.join(Soles.root, "config", "initializers", "**", "*.rb")).sort.each do |file|
        File.open(file) {|f| eval f.read, binding, file }      # rubocop:disable Lint/Eval
      end
    end    

    def setup_autoloader!
      ActiveSupport::Dependencies.hook!
    end
  end
end
