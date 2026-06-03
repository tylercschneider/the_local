# frozen_string_literal: true

require "test_helper"
require "rake"
require "active_support/all" # Rails::Railtie needs AS core exts; loaded by Rails in a real app
require "the_local/railtie"

module TheLocal
  class RailtieTest < Minitest::Test
    def test_is_a_rails_railtie
      assert_operator Railtie, :<, Rails::Railtie
    end

    def test_defines_the_refresh_rake_task
      app = Rake::Application.new
      Rake.application = app
      load File.expand_path("../../lib/the_local/tasks/the_local.rake", __dir__)

      assert app.lookup("the_local:refresh")
    end
  end
end
