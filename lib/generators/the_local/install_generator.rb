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
        allowed = Sync.new(
          registry: TheLocal.registry, destination: destination_root,
          direct_dependencies: direct_dependencies, bundled_gems: bundled_gems
        ).call
        say "the_local: installed locals for #{allowed.join(", ")}", :green
      end

      def wire_bin_setup
        return unless SetupHook.apply(File.join(destination_root, "bin/setup"))

        say "the_local: wired refresh into bin/setup", :green
      end

      private

      def direct_dependencies
        Bundler.definition.dependencies.map(&:name)
      end

      def bundled_gems
        Bundler.definition.specs.map(&:name)
      end
    end
  end
end
