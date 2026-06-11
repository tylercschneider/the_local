# frozen_string_literal: true

require_relative "reference"

module TheLocal
  # Registers the_local's own locals (info / install / develop) with the_local,
  # so the engine dogfoods the same provider model every other gem uses.
  module Companion
    SCOPE = "Claude Code locals: gems register subagents, the_local builds " \
            "committed .md and installs them into a host app"

    # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
    def self.register!
      TheLocal.register(
        "the_local",
        scope: SCOPE,
        agents_dir: File.expand_path("the_local/agents", __dir__)
      ) do |c|
        c.agent "info",
                description: "Use to learn how the_local works — providers, the build/install " \
                             "model, the delegation trigger, and the direct-dependency scope rule.",
                tools: "Read",
                body: "You explain how the_local works, answering only from the reference: providers " \
                      "register locals, the_local:build renders committed .md, install/refresh copy " \
                      "them verbatim into a host, the CLAUDE.md delegation trigger makes the host " \
                      "delegate, and only direct dependencies contribute. You make no changes.",
                knowledge: TheLocal::Reference.content

        c.agent "install",
                description: "Use to add the_local to a host app and set it up correctly.",
                tools: "Bash, Read, Edit",
                body: "You set the_local up in a host gem or app, following the reference's install " \
                      "section exactly: add the gem (git source until it is on RubyGems), bundle, run " \
                      "`bundle exec the_local install` to sync locals into .claude/agents/ and write " \
                      "the delegation trigger, and re-run it after bundle changes. You do not invent " \
                      "steps the reference does not list.",
                knowledge: TheLocal::Reference.content

        c.agent "develop",
                description: "Use PROACTIVELY to turn a gem into a the_local provider — scaffolding " \
                             "the companion, authoring the guide, and committing the rendered locals. " \
                             "MUST BE USED instead of wiring a provider by hand.",
                tools: "Read, Write, Edit, Grep",
                body: "You turn a gem into a the_local provider following the reference's " \
                      "provider-author workflow: run `the_local:provider`, write guide.md as the " \
                      "single source of truth (your own gem only), tailor the register block, and " \
                      "hook the_local:build into the Rakefile. The deliverable is the committed, " \
                      "shipped lib/<gem>/the_local/agents/*.md — that is the whole contract a host " \
                      "reads from disk; a host never loads the gem, so unless those files are built, " \
                      "committed, and in the gemspec, the gem contributes nothing. You keep them in " \
                      "sync with agent.to_markdown.",
                knowledge: TheLocal::Reference.content
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/BlockLength
  end
end

TheLocal::Companion.register!
