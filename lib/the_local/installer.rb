# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Writes the registry's agents into a destination's .claude/agents/ directory,
  # filtered to the host's allowed gems (its direct dependencies plus itself).
  # Plain Ruby — no Rails — so the install logic is fully testable; the Rails
  # generator is a thin wrapper over this.
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
        File.write(File.join(agents_dir, agent.filename), agent.to_markdown)
      end
    end

    private

    def installed_agents
      @registry.agents.select { |agent| @allowed_gems.include?(agent.gem_name) }
    end
  end
end
