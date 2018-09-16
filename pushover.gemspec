require File.expand_path('lib/pushover/version', __dir__)
Gem::Specification.new do |spec|
  spec.name = 'pushover'
  spec.authors       = ['Ernie Brodeur']
  spec.email         = ['ebrodeur@ujami.net']
  spec.date          = Time.now.strftime('%Y-%m-%d')
  spec.version       = Pushover::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.license       = 'MIT'

  # descriptions
  spec.description   = 'Api (and CLI) to interface with pushover.net'
  spec.summary       = 'This spec provides both an API and CLI interface to pushover.net.'
  spec.homepage      = 'https://gitlab.com/erniebrodeur/pushover'

  # files
  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # documentation
  spec.extra_rdoc_files = Dir.glob('*.md')
  spec.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Pushover', '--main', 'README.md', '--encoding=UTF-8']
  spec.has_rdoc = 'yard'

  # dependencies
  spec.add_runtime_dependency 'creatable'
  spec.add_runtime_dependency 'excon'
  spec.add_runtime_dependency 'gli'
  spec.add_runtime_dependency 'oj'

  # development dependencies
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'guard-yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-command'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'yard'
end
