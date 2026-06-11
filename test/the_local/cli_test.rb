# frozen_string_literal: true

require "test_helper"
require "the_local/cli"
require "minitest/mock"
require "stringio"

module TheLocal
  class CLITest < Minitest::Test
    def test_unknown_command_prints_usage
      out = StringIO.new
      CLI.new([], out: out).call

      assert_includes out.string, "Usage: the_local install"
    end

    def test_install_reports_the_synced_gems
      out = StringIO.new
      Refresh.stub(:call, %w[keystone_ui event_engine]) do
        CLI.new(["install"], out: out).call
      end

      assert_includes out.string, "installed locals for keystone_ui, event_engine"
    end

    def test_install_reminds_to_restart_the_session
      out = StringIO.new
      Refresh.stub(:call, %w[the_local]) do
        CLI.new(["install"], out: out).call
      end

      assert_includes out.string, "Restart your Claude Code session"
    end
  end
end
