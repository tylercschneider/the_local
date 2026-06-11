# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "minitest/mock"
require "tmpdir"

module TheLocal
  class RefreshTest < Minitest::Test
    Dep = Struct.new(:name)
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
                       require_bundle: -> {})

          assert_path_exists File.join(dir, ".claude/agents/keystone-develop.md")
          assert_path_exists File.join(dir, "CLAUDE.md")
        end
      end
    end

    def test_call_requires_the_bundle_so_unloaded_providers_register
      required = nil
      Dir.mktmpdir do |dir|
        Bundler.stub(:require, ->(*groups) { required = groups }) do
          definition = definition(direct: [], bundled: [], groups: %i[default development])
          Refresh.call(destination: dir, definition: definition)
        end
      end

      assert_equal %i[default development], required
    end

    def test_call_tolerates_a_bundled_gem_that_fails_to_load
      Dir.mktmpdir do |dir|
        crashing = ->(*) { raise NameError, "uninitialized constant Rails" }
        capture_io do
          Bundler.stub(:require, crashing) do
            Refresh.call(destination: dir, definition: definition(direct: [], bundled: [], groups: [:default]))
          end
        end

        assert_path_exists File.join(dir, "CLAUDE.md")
      end
    end
  end
end
