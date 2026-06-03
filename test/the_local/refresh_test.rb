# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TheLocal
  class RefreshTest < Minitest::Test
    Dep = Struct.new(:name)
    FakeDefinition = Struct.new(:dependencies, :specs)

    def setup
      TheLocal.reset!
    end

    def definition(direct:, bundled:)
      FakeDefinition.new(direct.map { |n| Dep.new(n) }, bundled.map { |n| Dep.new(n) })
    end

    def test_call_reads_the_definition_and_syncs_to_the_destination
      TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI work") do |c|
        c.agent "develop", description: "Build UI.", tools: "Read, Write, Edit", body: "…", knowledge: "API."
      end

      Dir.mktmpdir do |dir|
        Refresh.call(destination: dir, definition: definition(direct: ["keystone_ui"], bundled: ["keystone_ui"]))

        assert_path_exists File.join(dir, ".claude/agents/keystone-develop.md")
        assert_path_exists File.join(dir, "CLAUDE.md")
      end
    end
  end
end
