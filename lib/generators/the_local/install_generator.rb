# frozen_string_literal: true

require "rails/generators"
require "the_local"

module TheLocal
  module Generators
    # `bin/rails g the_local:install` — installs the locals contributed by the
    # app's direct dependencies (and the app itself) into .claude/agents/, and
    # writes the delegation trigger. A thin wrapper over the plain-Ruby engine.
    class InstallGenerator < Rails::Generators::Base
      desc "Install the Claude Code locals of this app's direct dependencies"

      def install_locals
        Installer.new(registry: TheLocal.registry, destination: destination_root, allowed_gems: allowed_gems).call
        TriggerWriter.new(registry: TheLocal.registry, destination: destination_root, allowed_gems: allowed_gems).call
        say "the_local: installed locals for #{allowed_gems.join(", ")}", :green
      end

      private

      def allowed_gems
        @allowed_gems ||= Scope.allowed_gems(
          provider_gem_names: TheLocal.registry.providers.map(&:gem_name),
          direct_dependencies: direct_dependencies,
          bundled_gems: bundled_gems
        )
      end

      def direct_dependencies
        Bundler.definition.dependencies.map(&:name)
      end

      def bundled_gems
        Bundler.definition.specs.map(&:name)
      end
    end
  end
end
