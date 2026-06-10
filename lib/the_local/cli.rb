# frozen_string_literal: true

require "the_local"

module TheLocal
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
    end

    def usage
      @out.puts "Usage: the_local install"
    end
  end
end
