# frozen_string_literal: true

module TheLocal
  # An immutable description of one Claude Code subagent contributed by a
  # provider (a gem or the app). Renders to a `.claude/agents/*.md` definition.
  #
  # +knowledge+ is a string or array of strings appended below the role body —
  # the provider's single-source reference(s).
  Agent = Data.define(:provider, :name, :description, :tools, :body, :knowledge) do
    def qualified_name
      "#{provider}-#{name}"
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
      MARKDOWN
    end
  end
end
