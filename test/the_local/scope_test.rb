# frozen_string_literal: true

require "test_helper"

module TheLocal
  class ScopeTest < Minitest::Test
    def allowed(provider_gem_names:, direct_dependencies:, bundled_gems:)
      Scope.allowed_gems(
        provider_gem_names: provider_gem_names,
        direct_dependencies: direct_dependencies,
        bundled_gems: bundled_gems
      )
    end

    def test_includes_a_direct_dependency_provider
      result = allowed(
        provider_gem_names: ["keystone_ui"],
        direct_dependencies: ["keystone_ui"],
        bundled_gems: ["keystone_ui"]
      )

      assert_equal ["keystone_ui"], result
    end
  end
end
