# frozen_string_literal: true

module TheLocal
  # A registered provider (gem or app): its gem name, filename prefix, and a
  # one-line scope used to generate the delegation trigger.
  Provider = Data.define(:gem_name, :prefix, :scope)

  # Accumulates the providers and agents contributed by everything that calls
  # TheLocal.register. The install generator reads this to write .claude/agents/
  # and the delegation trigger.
  class Registry
    def initialize
      @agents = []
      @providers = []
    end

    attr_reader :agents, :providers

    def add(agent)
      @agents << agent
    end

    def add_provider(provider)
      @providers << provider
    end

    def clear
      @agents.clear
      @providers.clear
    end
  end

  # Yielded to a provider's register block. Turns each `agent` call into an
  # Agent tagged with the providing gem and namespaced under its prefix.
  class Collector
    def initialize(gem_name, prefix, registry, agents_dir: nil)
      @gem_name = gem_name
      @prefix = prefix
      @registry = registry
      @agents_dir = agents_dir
    end

    def agent(name, description:, tools:, body:, knowledge: nil)
      @registry.add(
        Agent.new(gem_name: @gem_name, prefix: @prefix, name: name,
                  description: description, tools: tools, body: body, knowledge: knowledge,
                  source_path: source_path_for(name))
      )
    end

    private

    def source_path_for(name)
      return nil unless @agents_dir

      File.join(@agents_dir, "#{@prefix}-#{name}.md")
    end
  end
end
