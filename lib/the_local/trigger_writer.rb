# frozen_string_literal: true

module TheLocal
  # Writes the mandatory delegation trigger — the standing rule, read at the
  # start of every session, that tells the host agent to delegate to its locals
  # rather than work from memory. Generated from the registry's providers,
  # filtered to the host's allowed gems. Plain Ruby; the Rails generator wraps it.
  class TriggerWriter
    BEGIN_MARKER = "<!-- the_local:begin -->"
    END_MARKER = "<!-- the_local:end -->"

    def initialize(registry:, destination:, allowed_gems:, filename: "CLAUDE.md")
      @registry = registry
      @destination = destination
      @allowed_gems = allowed_gems
      @filename = filename
    end

    def call
      path = File.join(@destination, @filename)
      existing = File.exist?(path) ? File.read(path) : ""
      File.write(path, "#{merge(existing)}\n")
    end

    def rule
      <<~MARKDOWN.chomp
        #{BEGIN_MARKER}
        ## Delegate to your locals

        This project has installed expert subagents. Before doing work yourself,
        check whether a local owns it and delegate — never work from memory on
        something a local covers:

        #{bullets.join("\n")}

        See each agent's description for specifics.
        #{END_MARKER}
      MARKDOWN
    end

    private

    # Replaces an existing marked section in place, or appends one, so re-running
    # re-syncs the rule without duplicating or clobbering the host's own content.
    def merge(existing)
      section = /#{Regexp.escape(BEGIN_MARKER)}.*?#{Regexp.escape(END_MARKER)}/m
      return existing.sub(section, rule) if existing.match?(section)
      return rule if existing.strip.empty?

      "#{existing.chomp}\n\n#{rule}"
    end

    def bullets
      allowed_providers.map do |provider|
        target = "#{provider.prefix}-* agents"
        "- #{[provider.scope, target].compact.join(" → ")}"
      end
    end

    def allowed_providers
      @registry.providers.select { |provider| @allowed_gems.include?(provider.gem_name) }
    end
  end
end
