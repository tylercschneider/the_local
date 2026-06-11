# frozen_string_literal: true

require "rails/generators"
require "the_local/builder"

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
      RAKEFILE_REQUIRE = %(require "the_local/rake")

      desc "Scaffold the_local provider wiring (info/install/worker locals) into this gem"

      argument :gem_name, type: :string, desc: "The providing gem's name, e.g. citizen"
      class_option :prefix, type: :string,
                            desc: "Agent filename namespace (defaults to the gem name)"
      class_option :scope, type: :string, default: "TODO: one-line phrase describing this gem's domain",
                           desc: "One-line domain phrase used in the delegation trigger"
      class_option :worker, type: :string, default: "develop",
                            desc: "Name of the domain worker facet (develop for libraries, operate for CLIs)"

      def create_reference
        template "reference.rb.tt", "lib/#{lib_path}/reference.rb"
      end

      def create_guide
        template "guide.md.tt", "lib/#{lib_path}/reference/guide.md"
      end

      def create_companion
        template "the_local.rb.tt", "lib/#{lib_path}/the_local.rb"
      end

      def add_to_gemfile
        return if gem_name == "the_local"

        gemfile = File.join(destination_root, "Gemfile")
        return unless File.exist?(gemfile)
        return if File.read(gemfile).include?(GEMFILE_LINE)

        append_to_file "Gemfile",
                       "\n# Optional companion: #{gem_name} registers its locals with the_local " \
                       "when present.\n# Registration is guarded, so #{gem_name} works standalone.\n#{GEMFILE_LINE}\n"
      end

      def require_from_entrypoint
        entrypoint = File.join("lib", "#{lib_path}.rb")
        return unless File.exist?(File.join(destination_root, entrypoint))
        return if File.read(File.join(destination_root, entrypoint)).include?(require_line)

        append_to_file entrypoint,
                       "\n# Register #{gem_name}'s locals when the_local is present (no-op otherwise).\n" \
                       "#{require_line}\n"
      end

      def hook_build_task_into_rakefile
        return unless File.exist?(File.join(destination_root, "Rakefile"))
        return if File.read(File.join(destination_root, "Rakefile")).include?(RAKEFILE_REQUIRE)

        append_to_file "Rakefile",
                       "\n# Render #{gem_name}'s committed the_local agent files: `rake the_local:build`.\n" \
                       "require \"#{lib_path}\"\n#{RAKEFILE_REQUIRE}\n"
      end

      # Render the committed .md files now, so they land in the diff for review.
      # Loading the companion registers this gem's locals; reset first so only
      # they are built, not anything else the process may have registered.
      def build_agent_files
        companion = File.join(destination_root, "lib", lib_path, "the_local.rb")
        return unless File.exist?(companion)

        TheLocal.reset!
        load companion
        TheLocal::Builder.new(registry: TheLocal.registry).call
      end

      private

      def require_line
        %(require_relative "#{File.basename(lib_path)}/the_local")
      end

      def prefix
        options[:prefix] || gem_name
      end

      # Thor renders templates via File.binread, so the ERB buffer is ASCII-8BIT.
      # A UTF-8 scope would flip the buffer mid-render and then clash with the
      # template's own non-ASCII literals; match the buffer's encoding to avoid it.
      def scope
        options[:scope]&.b
      end

      def worker
        options[:worker]
      end

      def lib_path
        gem_name.tr("-", "/")
      end

      def module_name
        gem_name.split("-").map { |segment| segment.split("_").map(&:capitalize).join }.join("::")
      end

      def open_module
        module_name.split("::").map { |name| "module #{name}" }.join("\n")
      end

      def close_module
        module_name.split("::").map { "end" }.join("\n")
      end
    end
  end
end
