# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Copies each allowed provider's committed agent file into a destination's
  # .claude/agents/ directory, verbatim. Plain Ruby so the Rails generator is a
  # thin wrapper over it.
  class Installer
    AGENTS_DIR = ".claude/agents"

    def initialize(registry:, destination:, allowed_gems:)
      @registry = registry
      @destination = destination
      @allowed_gems = allowed_gems
    end

    def call
      agents_dir = File.join(@destination, AGENTS_DIR)
      FileUtils.mkdir_p(agents_dir)

      installed_agents.each do |agent|
        ensure_committed!(agent)
        FileUtils.cp(agent.source_path, File.join(agents_dir, agent.filename))
      end
    end

    private

    def installed_agents
      @registry.agents.select { |agent| @allowed_gems.include?(agent.gem_name) }
    end

    def ensure_committed!(agent)
      return if agent.source_path && File.exist?(agent.source_path)

      raise Error, "the_local: #{agent.gem_name} registered #{agent.qualified_name} without a committed " \
                   "agent file. Run `rake the_local:build` in #{agent.gem_name} and commit its the_local/agents/."
    end
  end
end
