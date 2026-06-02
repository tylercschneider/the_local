# frozen_string_literal: true

module TheLocal
  # Accumulates the agents contributed by every provider (gem or app) that calls
  # TheLocal.register. The install generator reads this to write .claude/agents/.
  class Registry
    def initialize
      @agents = []
    end

    attr_reader :agents

    def add(agent)
      @agents << agent
    end

    def clear
      @agents.clear
    end
  end

  # Yielded to a provider's register block. Turns each `agent` call into an
  # Agent tagged with the providing gem and namespaced under its prefix.
  class Collector
    def initialize(gem_name, prefix, registry)
      @gem_name = gem_name
      @prefix = prefix
      @registry = registry
    end

    def agent(name, description:, tools:, body:, knowledge: nil)
      @registry.add(
        Agent.new(gem_name: @gem_name, prefix: @prefix, name: name,
                  description: description, tools: tools, body: body, knowledge: knowledge)
      )
    end
  end
end
