# frozen_string_literal: true

require "rails/generators"
require "the_local"

module TheLocal
  module Generators
    # `bin/rails g the_local:install` — installs the locals contributed by the
    # app's direct dependencies into .claude/agents/, and writes the delegation
    # trigger. A thin wrapper over Refresh, which discovers providers from each
    # bundled gem's committed agents on disk.
    class InstallGenerator < Rails::Generators::Base
      desc "Install the Claude Code locals of this app's direct dependencies"

      def install_locals
        allowed = Refresh.call(destination: destination_root)
        say "the_local: installed locals for #{allowed.join(", ")}", :green
      end
    end
  end
end
