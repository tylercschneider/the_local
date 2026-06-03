# frozen_string_literal: true

module TheLocal
  # Re-syncs a host's locals from its current bundle. Gathers the direct and
  # bundled gem names from a Bundler definition and runs a Sync. The
  # `the_local:refresh` rake task is a one-line wrapper over this; the Bundler
  # definition is injectable so the logic stays testable without a real bundle.
  module Refresh
    def self.call(destination:, definition: Bundler.definition)
      Sync.new(
        registry: TheLocal.registry,
        destination: destination,
        direct_dependencies: definition.dependencies.map(&:name),
        bundled_gems: definition.specs.map(&:name)
      ).call
    end
  end
end
