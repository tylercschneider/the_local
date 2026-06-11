# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "tmpdir"
require "rails/generators"
require "generators/the_local/install_generator"

module TheLocal
  module Generators
    class InstallGeneratorTest < Minitest::Test
      def setup
        TheLocal.reset!
      end

      # The Rails generator is a thin wrapper: it delegates to Refresh, which
      # discovers providers from disk and syncs. The install behavior itself is
      # covered by RefreshTest; here we just confirm the wiring.
      def test_delegates_to_refresh_with_the_destination_root
        Dir.mktmpdir do |dir|
          captured = nil
          Refresh.stub(:call, ->(destination:) { captured = destination and ["keystone_ui"] }) do
            generator = InstallGenerator.new([], {}, destination_root: dir)
            capture_io { generator.install_locals }
          end

          assert_equal dir, captured
        end
      end
    end
  end
end
