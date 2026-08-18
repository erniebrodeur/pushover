# Project Conventions

## Ruby runtime

- Run Ruby, Bundler, Rake, RSpec, RuboCop, and other Ruby commands through `/opt/homebrew/bin/rbenv exec`.
- The Codex shell may resolve `/usr/bin/ruby` (Apple Ruby 2.6) instead of the project's Ruby version.
- The project runtime is defined by `.ruby-version`.

## HTTP client

- Use Excon for Pushover HTTP requests. Do not introduce another HTTP client without a specific need.
- Use Excon's request stubs for mocked HTTP tests.
- Consult the installed Excon documentation or source before assuming library behavior.
- it has no context 7 documentation, so read the source code for details.
