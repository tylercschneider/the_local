# frozen_string_literal: true

require "the_local"

module TheLocal
  class CLI
    def initialize(argv, out: $stdout)
      @argv = argv
      @out = out
    end

    def call
      usage
    end

    private

    def usage
      @out.puts "Usage: the_local install"
    end
  end
end
