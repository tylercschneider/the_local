# TheLocal

Resident Claude Code expert subagents ("locals"), contributed by the gems an app
uses. Any gem or app declares the locals that know its conventions; `the_local`
aggregates the locals of an app's installed providers into its
`.claude/agents/`, plus a delegation rule so the app's agent actually uses them.

A "local" is a Claude Code subagent that knows one gem's conventions cold. The
host's orchestrating agent delegates that gem's work to it, so usage stays
consistent instead of drifting.

## Installation

Add it to your Gemfile:

```ruby
gem "the_local"
```

or install it directly with `gem install the_local`. To track an unreleased
change, point at the repo instead:

```ruby
gem "the_local", github: "tylercschneider/the_local"
```

The gem's core is Rails-free, but the primary documented workflow uses the
`bin/rails g the_local:install` / `the_local:provider` generators, so those steps
assume a Rails host. The `the_local:refresh` rake task and the register API work
without Rails.

## Usage

There are two sides.

**Consuming app** — install the locals of the app's direct dependencies (and the
app's own) into `.claude/agents/`, and write the delegation trigger:

```bash
bin/rails g the_local:install
```

Install **copies each provider's committed `.md` verbatim** — the rendering
happens in the provider gem at build time, not in the host — so every app on the
same gem version gets a byte-identical local. Re-run `the_local:refresh` (rake)
after a `bundle install`/`update` to re-sync.

**Provider gem** — contribute the locals an app installs. A gem registers its
agents with `TheLocal.register` behind a soft guard, exposing the common command
interface (`info` / `install` / worker), then renders them to committed `.md`
with `rake the_local:build`. Scaffold it with:

```bash
bin/rails g the_local:provider <gem_name> --scope "the gem's domain"
```

See [PROVIDERS.md](PROVIDERS.md) for the full provider guide, including the
manual steps for non-Rails gems.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tylercschneider/the_local.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
