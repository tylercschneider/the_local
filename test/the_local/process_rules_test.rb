# frozen_string_literal: true

require "test_helper"
require "the_local/process_rules"

module TheLocal
  class ProcessRulesTest < Minitest::Test
    def test_content_includes_the_one_time_exception_rule
      assert_includes ProcessRules.content, "one-time exception"
    end
  end
end
