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

    def test_excludes_a_transitive_provider
      result = allowed(
        provider_gem_names: ["transitive_gem"],
        direct_dependencies: ["keystone_ui"],
        bundled_gems: %w[keystone_ui transitive_gem]
      )

      assert_equal [], result
    end

    def test_includes_the_app_itself_a_provider_that_is_not_a_bundled_gem
      result = allowed(
        provider_gem_names: ["my_app"],
        direct_dependencies: ["keystone_ui"],
        bundled_gems: ["keystone_ui"]
      )

      assert_equal ["my_app"], result
    end
  end
end
