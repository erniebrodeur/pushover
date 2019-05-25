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
  spec.homepage      = 'https://github.com/erniebrodeur/pushover'

  # files
  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # dependencies.
  spec.add_runtime_dependency 'creatable'
  spec.add_runtime_dependency 'excon'
  spec.add_runtime_dependency 'gli'
  spec.add_runtime_dependency 'oj'
end
