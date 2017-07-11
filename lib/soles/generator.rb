module Soles
  class Generator
    def initialize(name)
      @root = File.expand_path(File.join(Dir.pwd, name))
      @class_name = camelize(name)
    end

    def generate!
      copy ["app", "controllers", "application_controller.rb"]
      maybe_make "config/initializers"
      maybe_make "log"
      copy ["config", "app.rb"]
      copy ["..", "bin", "soles"], ["bin", "soles"], raw: true, mode: 0755

      %w(development test production).each do |env|
        @environment = env
        copy ["config", "configs", "environment.yml"], ["config", "configs", "#{env}.yml"]
        copy ["config", "environments", "environment.rb"], ["config", "environments", "#{env}.rb"]
      end
    end

    def maybe_make(dir, silent = false)
      target = dir[0] == "/" ? dir : File.join(@root, dir)
      if File.exists?(target)
        fail "Exists: #{relative target}/" unless silent
      else
        pass "Create: #{relative target}/"
        FileUtils.mkdir_p(target)
      end
    end

    def copy(template, filename = nil, options = {})
      source = File.expand_path(File.join(__FILE__, "..", "..", "..", "templates", *Array(template))) + (options.fetch(:raw, false) ? "" : ".erb")
      target = File.expand_path File.join(@root, *Array(filename || template))
      maybe_make File.dirname(target), true
      if File.exists?(target)
        fail "Exists: #{relative target}"
      else
        pass "Create: #{relative target}"
        open(target, "w") do |fp|
          fp.puts ERB.new(File.read(source)).result(binding)
        end
        if options.key?(:mode)
          File.chmod options[:mode], target
        end
      end
    end

    def relative(dir)
      dir.gsub("#{@root}/", "")
    end

    def camelize(string, uppercase_first_letter = true)
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      else
        string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end 

    def pass(label)
      puts format("%s - %s", ColorizedString["[\u2714]"].colorize(:green), label)
    end

    def fail(label)
      puts format("%s - %s", ColorizedString["[\u2718]"].colorize(:red), label)
    end
  end
end