# frozen_string_literal: true

require "test_helper"

module TheLocal
  class RegistryTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_scaffold
      TheLocal.register("keystone_ui", prefix: "keystone") do |c|
        c.agent "scaffold",
                description: "Use PROACTIVELY for UI work.",
                tools: "Read, Write, Edit",
                body: "You build UI.",
                knowledge: "API docs."
      end
    end

    def test_register_adds_the_agent_to_the_registry
      register_scaffold

      assert_equal ["keystone-scaffold.md"], TheLocal.registry.agents.map(&:filename)
    end

    def test_register_records_the_gem_name_for_dependency_filtering
      register_scaffold

      assert_equal ["keystone_ui"], TheLocal.registry.agents.map(&:gem_name)
    end

    def test_register_accumulates_agents_across_providers
      register_scaffold
      TheLocal.register("event_engine") do |c|
        c.agent "define", description: "…", tools: "Read", body: "…"
      end

      assert_equal ["keystone-scaffold.md", "event_engine-define.md"],
                   TheLocal.registry.agents.map(&:filename)
    end

    def test_register_wires_agent_attributes_through_to_the_rendered_markdown
      register_scaffold

      assert_includes TheLocal.registry.agents.first.to_markdown, "API docs."
    end

    def test_register_records_the_provider_with_its_scope
      TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI — pages, forms, tables") do |c|
        c.agent "scaffold", description: "…", tools: "Read", body: "…"
      end

      provider = TheLocal.registry.providers.first

      assert_equal ["keystone_ui", "keystone", "UI — pages, forms, tables"],
                   [provider.gem_name, provider.prefix, provider.scope]
    end
  end
end
