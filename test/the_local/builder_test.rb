# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class BuilderTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def test_writes_each_agent_markdown_to_its_source_path
      Dir.mktmpdir do |dir|
        TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
          c.agent "develop", description: "Build UI.", tools: "Read", body: "You build.", knowledge: "API."
        end

        Builder.new(registry: TheLocal.registry).call
        path = File.join(dir, "keystone-develop.md")

        assert_equal TheLocal.registry.agents.first.to_markdown, File.read(path)
      end
    end
  end
end
