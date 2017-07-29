require 'yaml'
require 'pathname'
require 'active_support/core_ext/hash/deep_merge'

module Soles
  class Configuration
    def initialize(env, files = [])
      @env = env
      @files = files.map {|f| Array(f) }
      @full = {}

      files.each do |file, merge_strategy|
        merge_strategy ||= :deep_merge!
        if File.exist?(file)
          open(file, "rb") do |fp|
            begin
              yaml = YAML.load(fp.read)
              @full.send merge_strategy, yaml
            rescue Psych::SyntaxError => e
              puts "ERROR: Could not parse #{file}. #{e.message}"
              raise
            end
          end
        end
      end
    end

    # Public: Retrieve a config key with dot syntax
    #
    # key - String of dot-delimited keys to step through
    # default - Value to return if the specified key does not exist
    #
    # Examples
    #
    #   config "foo.bar.baz", "default_value"
    #
    def value(key, default = nil)
      keys = key.split(".")
      r = recurse_config(@full[@env], keys.dup, :key_missing)
      if r == :key_missing
        recurse_config(@full["common"], keys.dup, default)
      else
        r
      end
    end

    # Internal: Helper method for stepping into configs.
    #
    # config - config object to step into
    # keys - Array of keys to recurse on
    # default - default value to return if the key doesn't exist
    def recurse_config(config, keys, default = nil)
      return default  unless config
      next_key = keys.shift
      if keys.empty?
        if config.key? next_key
          config[next_key]
        else
          default
        end
      elsif config.key? next_key
        recurse_config config[next_key], keys, default
      else
        default
      end
    end

    def autoload_paths
      ActiveSupport::Dependencies.autoload_paths
    end

    def autoload_paths=(paths)
      ActiveSupport::Dependencies.autoload_paths = paths.map do |p|
        path = Pathname.new(p)
        if path.absolute?
          p
        else
          File.join(Soles.root, p)
        end
      end
    end

    def method_missing(method, *args)
      if method.to_s.match(/=$/)
        self.class.send :attr_accessor, method.to_s.slice(0..-2)
        send method, *args
      end
    end
  end
end
