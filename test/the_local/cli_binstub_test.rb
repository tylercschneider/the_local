# frozen_string_literal: true

require "test_helper"

module TheLocal
  class CLIBinstubTest < Minitest::Test
    def test_binstub_runs_the_cli
      lib = File.expand_path("../../lib", __dir__)
      exe = File.expand_path("../../exe/the_local", __dir__)
      output = `ruby -I#{lib} #{exe} 2>&1`

      assert_includes output, "Usage: the_local install"
    end
  end
end
