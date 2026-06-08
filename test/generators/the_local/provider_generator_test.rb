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
    end
  end
end
