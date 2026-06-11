# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "minitest/mock"
require "fileutils"
require "tmpdir"

module TheLocal
  class RefreshTest < Minitest::Test
    Dep = Struct.new(:name)
    Spec = Struct.new(:name, :full_gem_path)
    FakeDefinition = Struct.new(:dependencies, :specs, :groups)

    def setup
      TheLocal.reset!
    end

    def definition(direct:, bundled:, groups: [])
      FakeDefinition.new(direct.map { |n| Dep.new(n) }, bundled.map { |n| Dep.new(n) }, groups)
    end

    def register_keystone(agents_dir:)
      TheLocal.register("keystone_ui", prefix: "keystone", scope: "UI work", agents_dir: agents_dir) do |c|
        c.agent "develop", description: "Build UI.", tools: "Read, Write, Edit", body: "…", knowledge: "API."
      end
      Builder.new(registry: TheLocal.registry).call
    end

    def test_call_reads_the_definition_and_syncs_to_the_destination
      Dir.mktmpdir do |gem_dir|
        register_keystone(agents_dir: gem_dir)

        Dir.mktmpdir do |dir|
          Refresh.call(destination: dir, definition: definition(direct: ["keystone_ui"], bundled: ["keystone_ui"]),
                       load_providers: -> {})

          assert_path_exists File.join(dir, ".claude/agents/keystone-develop.md")
          assert_path_exists File.join(dir, "CLAUDE.md")
        end
      end
    end

    def test_call_installs_committed_agents_discovered_on_disk
      Dir.mktmpdir do |gem_dir|
        agents = File.join(gem_dir, "lib/widgets/the_local/agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "widgets-info.md"), "---\nname: widgets-info\ntools: Read\n---\n\nbody\n")
        definition = FakeDefinition.new([Dep.new("widgets")], [Spec.new("widgets", gem_dir)], [:default])

        Dir.mktmpdir do |host|
          Refresh.call(destination: host, definition: definition)

          assert_path_exists File.join(host, ".claude/agents/widgets-info.md")
        end
      end
    end
  end
end
