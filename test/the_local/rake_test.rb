# frozen_string_literal: true

require "test_helper"
require "rake"

module TheLocal
  class RakeTest < Minitest::Test
    def test_defines_the_build_rake_task
      app = Rake::Application.new
      Rake.application = app
      load File.expand_path("../../lib/the_local/rake.rb", __dir__)

      assert app.lookup("the_local:build")
    end
  end
end
