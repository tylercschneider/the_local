# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "rails/generators"
require "generators/the_local/provider_generator"

module TheLocal
  module Generators
    # Drives `the_local:provider`, the generator that scaffolds the provider
    # wiring (the common info/install/worker command interface) into a gem.
    class ProviderGeneratorTest < Minitest::Test
      def setup
        TheLocal.reset!
      end

      # Seed a minimal fake gem (Gemfile + entrypoint) and run the generator
      # into it, non-interactively.
      def run_generator_into(dir, args = ["demo"])
        File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
        Dir.mkdir(File.join(dir, "lib"))
        File.write(File.join(dir, "lib", "demo.rb"), "# frozen_string_literal: true\n\nmodule Demo\nend\n")
        capture_io { ProviderGenerator.start(args, destination_root: dir) }
      end

      def test_scaffolds_the_companion_registration_file
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_path_exists File.join(dir, "lib/demo/the_local.rb")
        end
      end

      def test_scaffolds_the_reference_loader
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_path_exists File.join(dir, "lib/demo/reference.rb")
        end
      end

      def test_scaffolds_the_knowledge_guide
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_path_exists File.join(dir, "lib/demo/reference/guide.md")
        end
      end

      def test_adds_the_local_as_a_soft_dependency_to_the_gemfile
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Gemfile")),
                          %(gem "the_local", github: "tylercschneider/the_local")
        end
      end

      def test_gemfile_injection_is_idempotent_on_rerun
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          rerun = ProviderGenerator.new(["demo"], {}, destination_root: dir)
          capture_io { rerun.add_to_gemfile }

          assert_equal 1, File.read(File.join(dir, "Gemfile")).scan(ProviderGenerator::GEMFILE_LINE).size
        end
      end

      def test_requires_the_companion_from_the_gem_entrypoint
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "lib/demo.rb")),
                          %(require_relative "demo/the_local")
        end
      end

      # The scaffolded companion must register the common command interface that
      # every provider exposes to apps: info, install, and the domain worker.
      def test_companion_registers_the_common_command_interface
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          load File.join(dir, "lib/demo/the_local.rb")

          assert_equal %w[info install develop], TheLocal.registry.agents.map(&:name)
        end
      end
    end
  end
end
