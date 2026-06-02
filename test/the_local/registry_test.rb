# frozen_string_literal: true

require "test_helper"

module TheLocal
  class RegistryTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_scaffold
      TheLocal.register("keystone") do |c|
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
  end
end
