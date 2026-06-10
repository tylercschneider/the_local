# frozen_string_literal: true

require "rake"
require "the_local"
require "the_local/builder"

# Gem-side build task. A provider adds `require "the_local/rake"` to its Rakefile
# (after loading the gem, so its locals are registered) and runs
# `rake the_local:build` to (re)render its committed .claude agent files from the
# registered definitions. Host apps don't use this — they install/refresh.
namespace :the_local do
  desc "Render this provider's committed agent files from its registered definitions"
  task :build do
    written = TheLocal::Builder.new(registry: TheLocal.registry).call
    puts "the_local: built #{written.length} agent file(s)"
  end
end
