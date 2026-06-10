# frozen_string_literal: true

module TheLocal
  # Loads the_local's own knowledge guide, embedded verbatim into its locals.
  module Reference
    DIR = File.expand_path("reference", __dir__)

    def self.content
      read("guide.md")
    end

    def self.read(name)
      File.read(File.join(DIR, name)).chomp
    end
  end
end
