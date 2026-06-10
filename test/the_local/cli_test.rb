# frozen_string_literal: true

require "test_helper"
require "the_local/cli"
require "stringio"

module TheLocal
  class CLITest < Minitest::Test
    def test_unknown_command_prints_usage
      out = StringIO.new
      CLI.new([], out: out).call

      assert_includes out.string, "Usage: the_local install"
    end
  end
end
