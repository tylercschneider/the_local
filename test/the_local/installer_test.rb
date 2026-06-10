# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class InstallerTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def build_keystone(agents_dir:, names: %w[scaffold])
      TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: agents_dir) do |c|
        names.each do |name|
          c.agent name, description: "Use PROACTIVELY for UI.", tools: "Read, Write, Edit",
                        body: "You build UI.", knowledge: "API docs."
        end
      end
      Builder.new(registry: TheLocal.registry).call
    end

    def install_into(dir, allowed_gems: ["keystone_ui"])
      Installer.new(registry: TheLocal.registry, destination: dir, allowed_gems: allowed_gems).call
    end

    def test_copies_the_committed_agent_file_verbatim
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir)
        File.write(TheLocal.registry.agents.first.source_path, "SHIPPED BY THE GEM")

        Dir.mktmpdir do |dir|
          install_into(dir)

          assert_equal "SHIPPED BY THE GEM", File.read(File.join(dir, ".claude/agents/keystone-scaffold.md"))
        end
      end
    end

    def test_skips_providers_outside_the_allowed_gems
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir)
        TheLocal.register("some_transitive_gem") { |c| c.agent "helper", description: "…", tools: "Read", body: "…" }

        Dir.mktmpdir do |dir|
          install_into(dir, allowed_gems: ["keystone_ui"])

          refute_path_exists File.join(dir, ".claude/agents/some_transitive_gem-helper.md")
        end
      end
    end

    def test_raises_an_actionable_error_when_an_allowed_agent_has_no_committed_file
      TheLocal.register("keystone_ui", prefix: "keystone") do |c|
        c.agent "scaffold", description: "…", tools: "Read", body: "…"
      end

      Dir.mktmpdir do |dir|
        error = assert_raises(TheLocal::Error) { install_into(dir) }

        assert_match(/keystone-scaffold/, error.message)
      end
    end

    def test_writes_every_allowed_agent
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir, names: %w[scaffold review])

        Dir.mktmpdir do |dir|
          install_into(dir, allowed_gems: ["keystone_ui"])

          assert_equal %w[keystone-review.md keystone-scaffold.md],
                       Dir.children(File.join(dir, ".claude/agents")).sort
        end
      end
    end
  end
end
