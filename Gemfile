source 'https://rubygems.org'

gemspec

group :development do
	# guard
	gem 'guard', require: false
	gem 'guard-yard', require: false
	gem 'guard-bundler', require: false
	gem 'guard-rspec', require: false
	gem 'guard-rubybeautify', require: false
	# stuff to spam the desktop (for most os's)
	gem 'growl', require: false
	gem 'libnotify', require: false
	gem 'rb-inotify', require: false
	gem 'rb-fsevent', require: false
	gem 'rb-fchange', require: false
end

group :test do
	gem 'rspec'
	gem 'rspec-core'
	gem 'rspec-expectations'
	gem 'rspec-mocks'
	gem 'simplecov', require: false
	gem 'simplecov-rcov', require: false
	gem 'simplecov-console', require: false
end

group :extended_testing do
  gem "childprocess"
end
