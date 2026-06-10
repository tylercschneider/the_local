## [Unreleased]

## [0.1.0] - 2026-06-02

- Initial release.
- `TheLocal.register` API for gems and apps to contribute Claude Code locals,
  behind a soft `require "the_local"` guard so providers work standalone.
- Provider build model: `TheLocal::Builder` + `rake the_local:build` render each
  agent to a committed `.md`; the installer copies those files verbatim.
- `the_local:install` and `the_local:provider` Rails generators, plus a
  rake-only `the_local:refresh` to re-sync a host after bundle changes.
- Direct-dependency install scope and a registry-generated delegation trigger
  written into the host's `CLAUDE.md`/`AGENTS.md`.
- the_local dogfoods itself as a provider (`the_local-info`/`-install`/`-develop`)
  and propagates a canonical develop-process doc into every host.
