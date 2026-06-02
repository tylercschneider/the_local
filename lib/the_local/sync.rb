# frozen_string_literal: true

module TheLocal
  # Orchestrates a full sync: resolves which gems are in scope (direct deps + the
  # app), writes their agents, and writes the delegation trigger. Plain Ruby so
  # both the install generator and the refresh rake task share one path. Returns
  # the allowed gem names (for reporting).
  class Sync
    def initialize(registry:, destination:, direct_dependencies:, bundled_gems:)
      @registry = registry
      @destination = destination
      @direct_dependencies = direct_dependencies
      @bundled_gems = bundled_gems
    end

    def call
      allowed = Scope.allowed_gems(
        provider_gem_names: @registry.providers.map(&:gem_name),
        direct_dependencies: @direct_dependencies,
        bundled_gems: @bundled_gems
      )
      Installer.new(registry: @registry, destination: @destination, allowed_gems: allowed).call
      TriggerWriter.new(registry: @registry, destination: @destination, allowed_gems: allowed).call
      allowed
    end
  end
end
