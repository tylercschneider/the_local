# frozen_string_literal: true

module TheLocal
  # Decides which providers' locals a host installs: its DIRECT dependencies plus
  # the host project itself — never transitive dependencies. A registered
  # provider is included when it is a direct dependency, or when it is not a
  # bundled gem at all (which means it is the app registering its own locals).
  module Scope
    def self.allowed_gems(provider_gem_names:, direct_dependencies:, bundled_gems:)
      provider_gem_names.uniq.select do |name|
        direct_dependencies.include?(name) || !bundled_gems.include?(name)
      end
    end
  end
end
