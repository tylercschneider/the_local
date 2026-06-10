# frozen_string_literal: true

require "test_helper"
require "the_local/process_doc_writer"
require "tmpdir"

module TheLocal
  class ProcessDocWriterTest < Minitest::Test
    def writer(dir)
      ProcessDocWriter.new(destination: dir)
    end

    def test_block_includes_the_one_time_exception_rule
      Dir.mktmpdir do |dir|
        assert_includes writer(dir).block, "one-time exception"
      end
    end

    def test_call_creates_claude_md_with_the_block_when_absent
      Dir.mktmpdir do |dir|
        writer(dir).call

        assert_equal "#{writer(dir).block}\n", File.read(File.join(dir, "CLAUDE.md"))
      end
    end

    def test_call_is_idempotent_across_reruns
      Dir.mktmpdir do |dir|
        writer(dir).call
        writer(dir).call

        assert_equal 1, File.read(File.join(dir, "CLAUDE.md")).scan(ProcessDocWriter::BEGIN_MARKER).size
      end
    end
  end
end
