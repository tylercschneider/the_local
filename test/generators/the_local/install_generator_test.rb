# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"
require "rails/generators"
require "generators/the_local/install_generator"

module TheLocal
  module Generators
    class InstallGeneratorTest < Minitest::Test
      def setup
        TheLocal.reset!
      end

      def register_keystone(agents_dir:)
        TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI work", agents_dir: agents_dir) do |c|
          c.agent "scaffold", description: "…", tools: "Read", body: "…"
        end
        Builder.new(registry: TheLocal.registry).call
      end

      def run_generator_into(dir, direct:, bundled:)
        generator = InstallGenerator.new([], {}, destination_root: dir)
        generator.stub(:direct_dependencies, direct) do
          generator.stub(:bundled_gems, bundled) do
            capture_io { generator.install_locals }
          end
        end
      end

      # Smoke integration test: register a provider, run the generator end to end
      # (stubbing the Bundler data), and confirm it both installs the agent file
      # and writes the delegation trigger into the destination.
      def test_installs_allowed_locals_and_writes_the_delegation_trigger
        Dir.mktmpdir do |gem_dir|
          register_keystone(agents_dir: gem_dir)

          Dir.mktmpdir do |dir|
            run_generator_into(dir, direct: ["keystone_ui"], bundled: ["keystone_ui"])

            assert_path_exists File.join(dir, ".claude/agents/keystone-scaffold.md")
            assert_path_exists File.join(dir, "CLAUDE.md")
          end
        end
      end
    end
  end
end
