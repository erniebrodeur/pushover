# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pushover/version'

Gem::Specification.new do |spec|
  spec.name          = "pushover"
  spec.authors       = ["Ernie Brodeur"]
  spec.email         = ["ebrodeur@ujami.net"]
  spec.date          = Time.now.strftime('%Y-%m-%d')
  spec.version       = Pushover::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.license       = "Beerware v42"

  # descriptions
  spec.description   = "Api (and CLI) to interface with pushover.net"
  spec.summary       = "This gem provides both an API and CLI interface to pushover.net."
  spec.homepage      = "https://github.com/erniebrodeur/pushover"

  #files
  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '~> 2.1.0'

  # documentation
  spec.extra_rdoc_files = Dir.glob("*.md")
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Pushover", "--main", "README.md", "--encoding=UTF-8"]
  spec.has_rdoc = 'yard'

  # dependencies.
  spec.add_runtime_dependency "excon"
  spec.add_runtime_dependency "commander"
  spec.add_runtime_dependency "oj"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
