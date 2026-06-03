# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TheLocal
  class SetupHookTest < Minitest::Test
    def with_bin_setup(contents)
      Dir.mktmpdir do |dir|
        path = File.join(dir, "bin/setup")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, contents)
        yield path
      end
    end

    def test_appends_a_guarded_refresh_block
      with_bin_setup("#!/usr/bin/env ruby\nputs 'setup'\n") do |path|
        SetupHook.apply(path)

        assert_includes File.read(path), "bin/rails the_local:refresh"
      end
    end

    def test_preserves_existing_setup_content
      with_bin_setup("#!/usr/bin/env ruby\nputs 'setup'\n") do |path|
        SetupHook.apply(path)

        assert File.read(path).start_with?("#!/usr/bin/env ruby\nputs 'setup'")
      end
    end

    def test_is_idempotent_across_reruns
      with_bin_setup("#!/usr/bin/env ruby\n") do |path|
        SetupHook.apply(path)
        SetupHook.apply(path)

        assert_equal 1, File.read(path).scan("the_local:refresh").size
      end
    end

    def test_no_op_when_bin_setup_is_absent
      Dir.mktmpdir do |dir|
        refute SetupHook.apply(File.join(dir, "bin/setup"))
      end
    end
  end
end
