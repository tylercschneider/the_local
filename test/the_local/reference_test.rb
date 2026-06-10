# frozen_string_literal: true

require "test_helper"
require "the_local/reference"

module TheLocal
  class ReferenceTest < Minitest::Test
    def test_content_reads_the_committed_guide
      assert_includes Reference.content, "## TheLocal"
    end
  end
end
