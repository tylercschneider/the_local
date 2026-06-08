# Becoming a provider

`the_local` has two sides. The **consuming-app** side (`bin/rails g
the_local:install`) installs the locals of an app's direct dependencies into
`.claude/agents/`. This document covers the **provider** side: how a gem
contributes the locals an app installs.

A provider registers its agents with `TheLocal.register` behind a soft
`require "the_local"` guard, so the gem keeps working when `the_local` is absent.

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
lib/<gem>/reference.rb         # the Reference loader (single source of truth)
lib/<gem>/reference/guide.md   # the knowledge, with TODO markers to fill in
lib/<gem>/the_local.rb         # Companion.register! — info / install / <worker>
Gemfile                        # + gem "the_local", github: …  (soft, dev/test)
lib/<gem>.rb                   # + require_relative "<gem>/the_local"
```

Then **fill in the scaffold** — this is the real work the generator can't do:

1. Write `reference/guide.md` as the complete user-facing API. Its **Install**
   section must be the exact, correct steps for *this* gem (for an engine:
   add the gem → `bundle install` → install + run migrations → wire concerns /
   initializers), not a generic placeholder.
2. Tailor the three agent `body:` strings in `the_local.rb` to the gem.
3. Add a `companion_test` asserting the facets register and each embeds
   `Reference.content` (see `test/generators/the_local/provider_generator_test.rb`
   and the anvil example).

## Adopting it — non-Rails gems (manual)

A plain gem has no `bin/rails`, so do the same four things by hand. Mirror
`anvil` (`anvil/lib/anvil/the_local.rb` + `anvil/lib/anvil/reference.rb`):

1. `lib/<gem>/reference.rb` — a `Reference` module with `DIR`, `content`, and
   `read(name)` reading from `lib/<gem>/reference/`.
2. `lib/<gem>/reference/guide.md` — the knowledge (single source of truth).
3. `lib/<gem>/the_local.rb` — a `Companion.register!` that calls
   `TheLocal.register("<gem>", scope: "…")` and declares the `info` / `install` /
   worker agents, followed by the guard:

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
