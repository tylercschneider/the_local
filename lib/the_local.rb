# frozen_string_literal: true

require_relative "the_local/version"
require_relative "the_local/agent"
require_relative "the_local/registry"

# Resident Claude Code expert subagents ("locals"), contributed by the gems and
# app that register with it and installed into a consuming app's .claude/agents/.
module TheLocal
  class Error < StandardError; end

  class << self
    def registry
      @registry ||= Registry.new
    end

    # Providers (gems or the app) call this at load time to contribute their
    # agents:
    #
    #   TheLocal.register("keystone") do |c|
    #     c.agent "scaffold", description: "…", tools: "…", body: "…", knowledge: "…"
    #   end
    def register(provider)
      yield Collector.new(provider, registry)
    end

    def reset!
      registry.clear
    end
  end
end
