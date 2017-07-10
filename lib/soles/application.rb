module Soles
  class Application
    def initialize(base_directory, options = {})
      Soles.root = base_directory
      parse_environment!(options)
      Soles.configuration = configuration(options)
      load_environment!
      load_initializers!
    end

    # Parse out command line parameters and Do Something(TM)
    def run
    end

    private

    def configuration(options)
      default_config_path = File.join(Soles.root, "config", "config", "**", "*.yml")
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
  end
end
