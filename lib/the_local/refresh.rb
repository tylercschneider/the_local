# frozen_string_literal: true

module TheLocal
  # Re-syncs a host's locals from its current bundle. Requires the bundle first
  # so every provider's register block runs — outside Rails nothing else loads
  # them, so unrequired providers would contribute no locals. Loading is
  # best-effort: a bundled gem that can't be required standalone (e.g. a Rails
  # engine outside a Rails app) is skipped, not fatal, so one fragile gem never
  # crashes the install. Then gathers the direct and bundled gem names from a
  # Bundler definition and runs a Sync. Both the require step and the definition
  # are injectable so the logic stays testable without a real bundle.
  module Refresh
    def self.call(destination:, definition: Bundler.definition,
                  require_bundle: -> { load_bundle(definition) })
      require_bundle.call
      Sync.new(
        registry: TheLocal.registry,
        destination: destination,
        direct_dependencies: definition.dependencies.map(&:name),
        bundled_gems: definition.specs.map(&:name)
      ).call
    end

    def self.load_bundle(definition)
      Bundler.require(*definition.groups)
    rescue ScriptError, StandardError => e
      warn "the_local: skipped part of the bundle while loading providers " \
           "(#{e.class}: #{e.message}); some locals may be missing."
    end
  end
end
