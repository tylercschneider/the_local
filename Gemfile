# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in the_local.gemspec
gemspec

gem "irb"
gem "rake", "~> 13.0"

gem "minitest", "~> 5.16"

gem "rubocop", "~> 1.21"
gem "rubocop-minitest", require: false
gem "rubocop-rake", require: false

# Only needed to exercise the Rails generator (bin/rails g the_local:install).
# The gem's core is Rails-free; the generator file requires rails/generators
# itself and is loaded only inside a Rails app.
gem "railties", ">= 7.0"
