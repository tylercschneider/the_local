# frozen_string_literal: true

require "rails/generators"

module TheLocal
  module Generators
    # `bin/rails g the_local:provider <gem_name>` — scaffolds the provider side
    # of the_local into a gem: a Reference loader, a knowledge guide, and a
    # Companion that registers the common command interface (info / install /
    # worker) via TheLocal.register behind a soft `require "the_local"` guard.
    #
    # The companion app side is `the_local:install`; this is its mirror for the
    # gems that *contribute* locals. See PROVIDERS.md.
    class ProviderGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      GEMFILE_LINE = %(gem "the_local", github: "tylercschneider/the_local")

      desc "Scaffold the_local provider wiring (info/install/worker locals) into this gem"

      argument :gem_name, type: :string, desc: "The providing gem's name, e.g. citizen"
      class_option :prefix, type: :string,
                   desc: "Agent filename namespace (defaults to the gem name)"
      class_option :scope, type: :string, default: "TODO: one-line phrase describing this gem's domain",
                   desc: "One-line domain phrase used in the delegation trigger"
      class_option :worker, type: :string, default: "develop",
                   desc: "Name of the domain worker facet (develop for libraries, operate for CLIs)"

      def create_reference
        template "reference.rb.tt", "lib/#{gem_name}/reference.rb"
      end

      def create_guide
        template "guide.md.tt", "lib/#{gem_name}/reference/guide.md"
      end

      def create_companion
        template "the_local.rb.tt", "lib/#{gem_name}/the_local.rb"
      end

      def add_to_gemfile
        gemfile = File.join(destination_root, "Gemfile")
        return unless File.exist?(gemfile)
        return if File.read(gemfile).include?(GEMFILE_LINE)

        append_to_file "Gemfile",
          "\n# Optional companion: #{gem_name} registers its locals with the_local " \
          "when present.\n# Registration is guarded, so #{gem_name} works standalone.\n#{GEMFILE_LINE}\n"
      end

      def require_from_entrypoint
        entrypoint = File.join("lib", "#{gem_name}.rb")
        return unless File.exist?(File.join(destination_root, entrypoint))
        return if File.read(File.join(destination_root, entrypoint)).include?(require_line)

        append_to_file entrypoint,
          "\n# Register #{gem_name}'s locals when the_local is available (no-op otherwise).\n#{require_line}\n"
      end

      private

      def require_line
        %(require_relative "#{gem_name}/the_local")
      end

      def prefix
        options[:prefix] || gem_name
      end

      def scope
        options[:scope]
      end

      def worker
        options[:worker]
      end

      def module_name
        gem_name.split(/[_-]/).map(&:capitalize).join
      end
    end
  end
end
