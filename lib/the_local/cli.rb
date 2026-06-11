# frozen_string_literal: true

require "the_local"

module TheLocal
  # Rails-free entrypoint for the `the_local` executable. `the_local install`
  # syncs the current bundle's locals into .claude/agents/, so a plain gem can
  # install without a Rails generator or a Rakefile.
  class CLI
    def initialize(argv, out: $stdout)
      @argv = argv
      @out = out
    end

    def call
      case @argv.first
      when "install" then install
      else usage
      end
    end

    private

    def install
      allowed = Refresh.call(destination: Dir.pwd)
      @out.puts "the_local: installed locals for #{allowed.join(", ")}"
      @out.puts "Restart your Claude Code session to use them — agents load at startup."
    end

    def usage
      @out.puts "Usage: the_local install"
    end
  end
end
