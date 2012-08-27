# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pushover/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ernie Brodeur"]
  gem.email         = ["ebrodeur@ujami.net"]
  gem.description   = "App (and CLI) to interface with pushover.net"
  gem.summary       = "This gem will provide both an API and CLI interface to pushover.net."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pushover"
  gem.require_paths = ["lib"]
  gem.version       = Pushover::VERSION
  gem.add_development_dependency('pry')
end
