# frozen_string_literal: true

module TheLocal
  # An immutable description of one Claude Code subagent contributed by a
  # provider (a gem or the app). Renders to a `.claude/agents/*.md` definition.
  #
  # +gem_name+ is the providing gem (used to filter to a host's direct
  # dependencies). +prefix+ is the filename namespace (often a shorter alias,
  # e.g. gem "keystone_ui" → prefix "keystone"). +knowledge+ is a string or
  # array of strings appended below the role body — the provider's reference(s).
  Agent = Data.define(:gem_name, :prefix, :name, :description, :tools, :body, :knowledge) do
    def qualified_name
      "#{prefix}-#{name}"
    end

    def filename
      "#{qualified_name}.md"
    end

    def to_markdown
      <<~MARKDOWN
        ---
        name: #{qualified_name}
        description: #{description}
        tools: #{tools}
        ---

        #{body}

        #{Array(knowledge).join("\n\n")}
      MARKDOWN
    end
  end
end
