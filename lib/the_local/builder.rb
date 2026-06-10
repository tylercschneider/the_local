# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Renders each registered agent's markdown to its committed source_path, so a
  # provider gem can commit the files and the host installer later copies them
  # verbatim (rather than rendering at install time). Plain Ruby — driven by the
  # the_local:build rake task a provider runs. Agents that declared no agents_dir
  # (and so have no source_path) are skipped: there is nowhere to write them.
  class Builder
    def initialize(registry:)
      @registry = registry
    end

    def call
      buildable_agents.map do |agent|
        FileUtils.mkdir_p(File.dirname(agent.source_path))
        File.write(agent.source_path, agent.to_markdown)
        agent.source_path
      end
    end

    private

    def buildable_agents
      @registry.agents.select(&:source_path)
    end
  end
end
