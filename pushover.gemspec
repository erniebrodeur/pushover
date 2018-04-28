# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pushover/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "pushover"
  gem.authors       = ["Ernie Brodeur"]
  gem.email         = ["ebrodeur@ujami.net"]
  gem.date          = Time.now.strftime('%Y-%m-%d')
  gem.version       = Pushover::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.license       = "Beerware v42"

  # descriptions
  gem.description   = "Api (and CLI) to interface with pushover.net"
  gem.summary       = "This gem provides both an API and CLI interface to pushover.net."
  gem.homepage      = "https://github.com/erniebrodeur/pushover"

  #files
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # documentation
  gem.extra_rdoc_files = Dir.glob("*.md")
  gem.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Pushover", "--main", "README.md", "--encoding=UTF-8"]
  gem.has_rdoc = 'yard'

  # dependencies.
  gem.add_runtime_dependency 'yajl-ruby', "= 1.4.0"
  gem.add_runtime_dependency 'httparty', "= 0.16.2"
  gem.add_runtime_dependency 'bini', "= 0.7.0"
end
