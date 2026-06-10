# frozen_string_literal: true

require_relative "process_rules"

module TheLocal
  # Writes the canonical develop-process rules into a host's CLAUDE.md as a
  # managed block, read at the start of every session so the host agent always
  # follows one source of truth. Re-propagated on every install/refresh. Uses
  # its own markers so it coexists with the delegation trigger in the same file.
  class ProcessDocWriter
    BEGIN_MARKER = "<!-- the_local:process:begin -->"
    END_MARKER = "<!-- the_local:process:end -->"
    RULES_FILENAME = "develop_process_rules.md"

    def initialize(destination:, filename: "CLAUDE.md")
      @destination = destination
      @filename = filename
    end

    def call
      File.write(File.join(@destination, RULES_FILENAME), "#{ProcessRules.content}\n")
      path = File.join(@destination, @filename)
      existing = File.exist?(path) ? File.read(path) : ""
      File.write(path, "#{merge(existing)}\n")
    end

    def block
      <<~MARKDOWN.chomp
        #{BEGIN_MARKER}
        #{ProcessRules.content}
        #{END_MARKER}
      MARKDOWN
    end

    private

    def merge(existing)
      section = /#{Regexp.escape(BEGIN_MARKER)}.*?#{Regexp.escape(END_MARKER)}/m
      return existing.sub(section, block) if existing.match?(section)
      return block if existing.strip.empty?

      "#{existing.chomp}\n\n#{block}"
    end
  end
end
