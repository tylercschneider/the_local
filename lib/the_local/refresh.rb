# frozen_string_literal: true

module TheLocal
  # Re-syncs a host's locals from its current bundle. Discovers providers by
  # reading their committed agent files from each bundled gem's path on disk
  # (see DiskProviders) — no gem code is loaded, so a fragile gem can't crash the
  # install and a provider needs no register/require wiring at install time to
  # contribute. Then gathers the direct and bundled gem names from a Bundler
  # definition and runs a Sync. Both the provider discovery and the definition
  # are injectable so the logic stays testable without a real bundle.
  module Refresh
    def self.call(destination:, definition: Bundler.definition,
                  load_providers: -> { DiskProviders.load(registry: TheLocal.registry, specs: specs_from(definition)) })
      load_providers.call
      Sync.new(
        registry: TheLocal.registry,
        destination: destination,
        direct_dependencies: definition.dependencies.map(&:name),
        bundled_gems: definition.specs.map(&:name)
      ).call
    end

    def self.specs_from(definition)
      definition.specs.map { |spec| { name: spec.name, path: spec.full_gem_path } }
    end
  end
end
