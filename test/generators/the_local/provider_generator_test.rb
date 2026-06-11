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

      # Seed a namespaced/hyphenated gem: name event_engine-subscribers, module
      # EventEngine::Subscribers, entrypoint lib/event_engine/subscribers.rb.
      def run_namespaced_generator_into(dir)
        File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
        FileUtils.mkdir_p(File.join(dir, "lib", "event_engine"))
        File.write(File.join(dir, "lib", "event_engine", "subscribers.rb"),
                   "# frozen_string_literal: true\n\nmodule EventEngine\n  module Subscribers\n  end\nend\n")
        capture_io { ProviderGenerator.start(["event_engine-subscribers"], destination_root: dir) }
      end

      # Reloading the same generated companion across tests redefines its
      # register! method; silence that expected warning while loading.
      def load_companion(path)
        previous = $VERBOSE
        $VERBOSE = nil
        load path
      ensure
        $VERBOSE = previous
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
                          %(gem "the_local"\n)
        end
      end

      def test_does_not_add_a_self_reference_when_the_local_provisions_itself
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
          generator = ProviderGenerator.new(["the_local"], {}, destination_root: dir)
          capture_io { generator.add_to_gemfile }

          refute_includes File.read(File.join(dir, "Gemfile")), ProviderGenerator::GEMFILE_LINE
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

      def test_renders_the_companion_with_a_non_ascii_scope
        Dir.mktmpdir do |dir|
          run_generator_into(dir, ["demo", "--scope", "UI work — components and recipes"])

          assert_includes File.read(File.join(dir, "lib/demo/the_local.rb")),
                          %(scope: "UI work — components and recipes")
        end
      end

      def test_builds_the_committed_agent_files_on_scaffold
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_path_exists File.join(dir, "lib/demo/the_local/agents/demo-info.md")
        end
      end

      def test_hooks_the_build_task_into_the_rakefile
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "Rakefile"), "# frozen_string_literal: true\n")
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Rakefile")), %(require "the_local/rake")
        end
      end

      # The committed .md files live beside the companion, under
      # lib/<gem>/the_local/agents/, so the host installer can copy them verbatim.
      def test_companion_registers_agents_with_a_committed_source_path
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          TheLocal.reset!
          load_companion(File.join(dir, "lib/demo/the_local.rb"))

          assert TheLocal.registry.agents.first.source_path.end_with?("lib/demo/the_local/agents/demo-info.md")
        end
      end

      # The scaffolded companion must register the common command interface that
      # every provider exposes to apps: info, install, and the domain worker.
      def test_companion_registers_the_common_command_interface
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          TheLocal.reset!
          load_companion(File.join(dir, "lib/demo/the_local.rb"))

          assert_equal %w[info install develop], TheLocal.registry.agents.map(&:name)
        end
      end

      def test_scaffolds_nested_modules_at_the_namespaced_path_for_a_hyphenated_gem
        Dir.mktmpdir do |dir|
          run_namespaced_generator_into(dir)

          assert_includes File.read(File.join(dir, "lib/event_engine/subscribers/the_local.rb")),
                          "module EventEngine\nmodule Subscribers"
        end
      end

      def test_requires_the_companion_from_the_namespaced_entrypoint
        Dir.mktmpdir do |dir|
          run_namespaced_generator_into(dir)

          assert_includes File.read(File.join(dir, "lib/event_engine/subscribers.rb")),
                          %(require_relative "subscribers/the_local")
        end
      end

      def test_hooks_the_build_task_with_the_namespaced_require
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "Rakefile"), "# frozen_string_literal: true\n")
          run_namespaced_generator_into(dir)

          assert_includes File.read(File.join(dir, "Rakefile")), %(require "event_engine/subscribers")
        end
      end

      # An engine can only run the generator from test/dummy, so destination_root
      # is the dummy app; the generator must relocate to the gem root (the nearest
      # ancestor with a *.gemspec) before writing.
      def test_writes_to_the_gem_root_when_run_from_a_dummy_app
        Dir.mktmpdir do |gem_root|
          File.write(File.join(gem_root, "demo.gemspec"), "# dummy gemspec\n")
          File.write(File.join(gem_root, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
          FileUtils.mkdir_p(File.join(gem_root, "lib"))
          File.write(File.join(gem_root, "lib", "demo.rb"), "# frozen_string_literal: true\n\nmodule Demo\nend\n")
          dummy = File.join(gem_root, "test", "dummy")
          FileUtils.mkdir_p(dummy)
          capture_io { ProviderGenerator.start(["demo"], destination_root: dummy) }

          assert_path_exists File.join(gem_root, "lib/demo/the_local.rb")
        end
      end
    end
  end
end
