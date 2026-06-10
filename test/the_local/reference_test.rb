# frozen_string_literal: true

require "test_helper"
require "the_local/reference"

module TheLocal
  class ReferenceTest < Minitest::Test
    def test_content_reads_the_committed_guide
      assert_includes Reference.content, "## TheLocal"
    end

    def test_install_section_leads_with_the_cli
      assert_includes Reference.content, "bundle exec the_local install"
    end
  end
end
