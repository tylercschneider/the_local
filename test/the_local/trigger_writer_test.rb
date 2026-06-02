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
  end
end
