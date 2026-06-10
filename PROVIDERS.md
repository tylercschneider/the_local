# Becoming a provider

`the_local` has two sides. The **consuming-app** side (`bin/rails g
the_local:install`) installs the locals of an app's direct dependencies into
`.claude/agents/`. This document covers the **provider** side: how a gem
contributes the locals an app installs.

A provider registers its agents with `TheLocal.register` behind a soft
`require "the_local"` guard, so the gem keeps working when `the_local` is absent.

## Build at home, copy verbatim

The agent *definition* (`the_local.rb` + `guide.md`) is the single source of
truth. The provider **renders it to committed `.md` files** with a gem-side
`the_local:build` task and commits those files to its own repo; the host install
then **copies them verbatim** into `.claude/agents/`. No rendering happens in the
host.

So the rendered output depends only on the provider gem version — every app that
installs the same version gets a byte-identical local, instead of the host
re-rendering (and possibly drifting) from an in-memory definition. The committed
`.md` is a reviewable build artifact: it lands in the gem's own PR. Keep it in
sync with the definition by re-running `the_local:build` and committing the
result whenever you change the guide or an agent's `body:`/`description:`.

## The common command interface

`the_local` exists to give every gem the **same command interface to apps**, so
a host agent always finds the same shape no matter which gem it's delegating to.
A provider exposes three lifecycle facets:

| Facet | Purpose | Typical tools |
|---|---|---|
| **`info`** | Read-only. Explains what the gem offers — its API and conventions. Makes no changes. | `Read` |
| **`install`** | Adds the gem to a host and sets it up **correctly** — the exact, gem-specific steps. | `Bash, Read, Edit` |
| **worker** | The proactive domain worker the host routes real work to. Named `develop` for libraries you build against, `operate` for CLIs you run. | per domain |

`info` and `install` are universal; the worker's name varies by the gem's
nature. Every agent embeds the provider's knowledge (`Reference.content`)
verbatim — that knowledge is the single source of truth, so the locals never
drift from the docs.

## Adopting it — Rails-engine gems (generator)

If the gem has Rails available in development (e.g. a mountable engine), scaffold
the wiring with the generator:

```bash
bin/rails g the_local:provider <gem_name> \
  --scope "one-line phrase describing the gem's domain" \
  [--prefix <filename-namespace>] \
  [--worker develop|operate]
```

It creates, and wires up:

```
lib/<gem>/reference.rb           # the Reference loader (single source of truth)
lib/<gem>/reference/guide.md     # the knowledge, with TODO markers to fill in
lib/<gem>/the_local.rb           # Companion.register! — info / install / <worker>
lib/<gem>/the_local/agents/*.md  # the rendered locals, built + committed
Gemfile                          # + gem "the_local", github: …  (soft, dev/test)
lib/<gem>.rb                     # + require_relative "<gem>/the_local"
Rakefile                         # + require "the_local/rake"  (rake the_local:build)
```

The generator builds the `.md` once on scaffold so they land in the diff for
review. They are rendered from the TODO placeholder definition, so you rebuild
them after filling in the real content (below).

Then **fill in the scaffold** — this is the real work the generator can't do:

1. Write `reference/guide.md` as the complete user-facing API. Its **Install**
   section must be the exact, correct steps for *this* gem (for an engine:
   add the gem → `bundle install` → install + run migrations → wire concerns /
   initializers), not a generic placeholder.
2. Tailor the three agent `body:` strings in `the_local.rb` to the gem.
3. **Rebuild and commit the locals.** The scaffold built `.md` from the TODO
   placeholders, so regenerate them from your real definition and commit them:

   ```bash
   rake the_local:build
   git add lib/<gem>/the_local/agents
   ```

   Rebuild whenever the guide or an agent's `body:`/`description:` changes — the
   host copies these bytes verbatim, so a stale commit ships stale locals.
4. Add a `companion_test` asserting the facets register and each embeds
   `Reference.content`, plus a **drift test** asserting each committed file
   equals its `agent.to_markdown` (so a forgotten rebuild fails CI). See
   `test/the_local/companion_test.rb` — the_local is its own provider and uses
   exactly this wiring.

## Adopting it — non-Rails gems (manual)

A plain gem has no `bin/rails`, so do the same things by hand. `the_local` is
itself a non-Rails provider built this way — mirror its own wiring
(`lib/the_local/the_local.rb`, `lib/the_local/reference.rb`, the committed
`lib/the_local/the_local/agents/`, and the `Rakefile`):

1. `lib/<gem>/reference.rb` — a `Reference` module with `DIR`, `content`, and
   `read(name)` reading from `lib/<gem>/reference/`.
2. `lib/<gem>/reference/guide.md` — the knowledge (single source of truth).
3. `lib/<gem>/the_local.rb` — a `Companion.register!` that calls `TheLocal.register`
   with an `agents_dir` (where the committed `.md` live) and declares the
   `info` / `install` / worker agents, followed by the guard:

   ```ruby
   TheLocal.register("<gem>", scope: "…",
                     agents_dir: File.expand_path("the_local/agents", __dir__)) do |c|
     # c.agent "info", …
   end
   ```

   ```ruby
   begin
     require "the_local"
     <Gem>::Companion.register!
   rescue LoadError
     # the_local not installed — <gem> works standalone.
   end
   ```
4. `require_relative "<gem>/the_local"` from the gem's entrypoint, and add
   `gem "the_local", github: "tylercschneider/the_local"` to the Gemfile
   (dev/test — it's an optional companion, not a hard dependency).
5. Add `require "the_local/rake"` to the `Rakefile`, then build and commit the
   rendered locals — `rake the_local:build && git add lib/<gem>/the_local/agents`.
   These committed bytes are what the host copies; rebuild on every change.
