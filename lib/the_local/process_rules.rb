# frozen_string_literal: true

module TheLocal
  # Loads the canonical develop-process rules the_local propagates into every
  # host, so a host agent reads and follows one source of truth.
  module ProcessRules
    DIR = File.expand_path("process_rules", __dir__)

    def self.content
      read("develop_process_rules.md")
    end

    def self.read(name)
      File.read(File.join(DIR, name)).chomp
    end
  end
end
