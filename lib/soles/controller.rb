module Soles
  class Controller < Thor
    extend ActiveSupport::DescendantsTracker

    def self.describes(name, desc)
      @thor_namespace = name.to_s
      @thor_desc = desc.to_s
      namespace name
    end

    def self.register_in(owner)
      owner.desc @thor_namespace || self.name, @thor_desc || self.name
      owner.subcommand @thor_namespace || self.name, self
    end
  end
end
