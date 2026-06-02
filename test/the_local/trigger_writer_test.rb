# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TheLocal
  class TriggerWriterTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_keystone
      TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI — pages, forms, tables") do |c|
        c.agent "scaffold", description: "…", tools: "Read", body: "…"
      end
    end

    def writer(dir, allowed_gems: ["keystone_ui"])
      TriggerWriter.new(registry: TheLocal.registry, destination: dir, allowed_gems: allowed_gems)
    end

    def test_rule_lists_a_delegation_bullet_per_provider
      register_keystone

      Dir.mktmpdir do |dir|
        assert_includes writer(dir).rule, "- UI — pages, forms, tables → keystone-* agents"
      end
    end

    def test_rule_excludes_providers_outside_the_allowed_gems
      register_keystone
      TheLocal.register("some_transitive_gem", scope: "internal") do |c|
        c.agent "helper", description: "…", tools: "Read", body: "…"
      end

      Dir.mktmpdir do |dir|
        refute_includes writer(dir, allowed_gems: ["keystone_ui"]).rule, "some_transitive_gem"
      end
    end

    def test_call_creates_claude_md_with_the_rule_when_absent
      register_keystone

      Dir.mktmpdir do |dir|
        writer(dir).call

        assert_equal "#{writer(dir).rule}\n", File.read(File.join(dir, "CLAUDE.md"))
      end
    end

    def test_call_is_idempotent_across_reruns
      register_keystone

      Dir.mktmpdir do |dir|
        writer(dir).call
        writer(dir).call

        assert_equal 1, File.read(File.join(dir, "CLAUDE.md")).scan(TriggerWriter::BEGIN_MARKER).size
      end
    end

    def test_call_preserves_existing_claude_md_content
      register_keystone

      Dir.mktmpdir do |dir|
        path = File.join(dir, "CLAUDE.md")
        File.write(path, "# My App\n\nHouse rules.\n")
        writer(dir).call

        assert File.read(path).start_with?("# My App\n\nHouse rules.")
      end
    end
  end
end
