# frozen_string_literal: true

require "test_helper"

module TheLocal
  class AgentTest < Minitest::Test
    def build(**overrides)
      defaults = {
        provider: "keystone", name: "scaffold",
        description: "Use PROACTIVELY for UI work.",
        tools: "Read, Write, Edit", body: "You build UI.", knowledge: "API docs."
      }
      Agent.new(**defaults.merge(overrides))
    end

    def test_filename_namespaces_the_agent_under_its_provider
      assert_equal "keystone-scaffold.md", build.filename
    end

    def test_to_markdown_opens_with_yaml_frontmatter
      assert build.to_markdown.start_with?(<<~FRONTMATTER)
        ---
        name: keystone-scaffold
        description: Use PROACTIVELY for UI work.
        tools: Read, Write, Edit
        ---
      FRONTMATTER
    end

    def test_to_markdown_includes_the_role_body_after_the_frontmatter
      assert_includes build(body: "You build UI from helpers.").to_markdown, "You build UI from helpers."
    end

    def test_to_markdown_appends_string_knowledge
      assert_includes build(knowledge: "THE-API-REFERENCE").to_markdown, "THE-API-REFERENCE"
    end
  end
end
