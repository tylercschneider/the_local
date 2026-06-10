# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Copies each allowed provider's committed agent file into a destination's
  # .claude/agents/ directory, verbatim — the gem renders and commits the file
  # (via the_local:build), the host installs the exact bytes rather than
  # re-rendering. Filtered to the host's allowed gems (its direct dependencies
  # plus itself). Plain Ruby — no Rails — so the install logic is fully testable;
  # the Rails generator is a thin wrapper over this.
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
        FileUtils.cp(agent.source_path, File.join(agents_dir, agent.filename))
      end
    end

    private

    def installed_agents
      @registry.agents.select { |agent| @allowed_gems.include?(agent.gem_name) }
    end
  end
end
