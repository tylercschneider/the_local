# frozen_string_literal: true

require "rails/railtie"
require "the_local"

module TheLocal
  # Minimal Railtie whose only job is to expose the `the_local:refresh` rake task
  # to the host app. Registration deliberately does NOT use a Railtie (it happens
  # at gem load — see the design plan); this is purely task exposure.
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks/the_local.rake", __dir__)
    end
  end
end
