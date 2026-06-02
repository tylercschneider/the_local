# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TheLocal
  class InstallerTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_keystone
      TheLocal.register("keystone_ui", prefix: "keystone") do |c|
        c.agent "scaffold", description: "Use PROACTIVELY for UI.",
                            tools: "Read, Write, Edit", body: "You build UI.", knowledge: "API docs."
      end
    end

    def install_into(dir, allowed_gems: ["keystone_ui"])
      Installer.new(registry: TheLocal.registry, destination: dir, allowed_gems: allowed_gems).call
    end

    def test_writes_an_allowed_agent_file_with_its_markdown
      register_keystone

      Dir.mktmpdir do |dir|
        install_into(dir)
        path = File.join(dir, ".claude/agents/keystone-scaffold.md")

        assert_equal TheLocal.registry.agents.first.to_markdown, File.read(path)
      end
    end

    def test_skips_providers_outside_the_allowed_gems
      register_keystone
      TheLocal.register("some_transitive_gem") do |c|
        c.agent "helper", description: "…", tools: "Read", body: "…"
      end

      Dir.mktmpdir do |dir|
        install_into(dir, allowed_gems: ["keystone_ui"])

        refute_path_exists File.join(dir, ".claude/agents/some_transitive_gem-helper.md")
      end
    end
  end
end
