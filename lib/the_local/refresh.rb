# frozen_string_literal: true

module TheLocal
  # Re-syncs a host's locals from its current bundle. Requires the bundle first
  # so every provider's register block runs — outside Rails nothing else loads
  # them, so unrequired providers would contribute no locals. Then gathers the
  # direct and bundled gem names from a Bundler definition and runs a Sync. Both
  # the require step and the definition are injectable so the logic stays
  # testable without a real bundle.
  module Refresh
    def self.call(destination:, definition: Bundler.definition,
                  require_bundle: -> { Bundler.require(*definition.groups) })
      require_bundle.call
      Sync.new(
        registry: TheLocal.registry,
        destination: destination,
        direct_dependencies: definition.dependencies.map(&:name),
        bundled_gems: definition.specs.map(&:name)
      ).call
    end
  end
end
