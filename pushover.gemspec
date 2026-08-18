require File.expand_path('lib/pushover/version', __dir__)
Gem::Specification.new do |spec|
  spec.name = 'pushover'
  spec.authors       = ['Ernie Brodeur']
  spec.email         = ['ebrodeur@ujami.net']
  spec.version       = Pushover::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.3.0'
  spec.license       = 'MIT'

  # descriptions
  spec.description   = 'Api (and CLI) to interface with pushover.net'
  spec.summary       = 'This spec provides both an API and CLI interface to pushover.net.'
  spec.homepage      = 'https://github.com/erniebrodeur/pushover'

  # files
  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # dependencies.
  spec.add_dependency 'excon'
  spec.add_dependency 'gli'
  spec.add_dependency 'oj'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
