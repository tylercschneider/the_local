# frozen_string_literal: true

require "test_helper"

module TheLocal
  class CompanionTest < Minitest::Test
    def setup
      TheLocal.reset!
      TheLocal::Companion.register!
    end

    def test_registers_the_common_command_interface
      assert_equal %w[the_local-info the_local-install the_local-develop],
                   TheLocal.registry.agents.map(&:qualified_name)
    end

    def test_committed_agent_files_match_the_registration
      TheLocal.registry.agents.each do |agent|
        assert_equal agent.to_markdown, File.read(agent.source_path)
      end
    end
  end
end
