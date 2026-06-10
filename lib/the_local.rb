# frozen_string_literal: true

require_relative "the_local/version"
require_relative "the_local/agent"
require_relative "the_local/registry"
require_relative "the_local/installer"
require_relative "the_local/trigger_writer"
require_relative "the_local/scope"
require_relative "the_local/sync"
require_relative "the_local/refresh"

# Resident Claude Code expert subagents ("locals"), contributed by the gems and
# app that register with it and installed into a consuming app's .claude/agents/.
module TheLocal
  class Error < StandardError; end

  class << self
    def registry
      @registry ||= Registry.new
    end

    # Providers (gems or the app) call this at load time to contribute their
    # agents. The first argument is the providing gem's name (used to filter to a
    # host's direct dependencies); +prefix+ is the agent filename namespace and
    # defaults to the gem name; +scope+ is a one-line phrase describing the
    # provider's domain, used to generate the delegation trigger. +agents_dir+
    # is the absolute path to the provider's committed, pre-rendered .md files
    # (e.g. File.expand_path("the_local/agents", __dir__)); when given, each
    # agent records its source_path there for the host installer to copy:
    #
    #   TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI work") do |c|
    #     c.agent "scaffold", description: "…", tools: "…", body: "…", knowledge: "…"
    #   end
    def register(gem_name, prefix: gem_name, scope: nil, agents_dir: nil)
      registry.add_provider(Provider.new(gem_name: gem_name, prefix: prefix, scope: scope))
      yield Collector.new(gem_name, prefix, registry, agents_dir: agents_dir)
    end

    def reset!
      registry.clear
    end
  end
end

# In a Rails host, expose the the_local:refresh rake task. Skipped outside Rails
# so the gem core stays Rails-free.
require_relative "the_local/railtie" if defined?(Rails::Railtie)

require_relative "the_local/the_local"
