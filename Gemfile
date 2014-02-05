source 'https://rubygems.org'

gemspec

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end

group :development do
  gem "pry",           :require => false
  gem "guard",         :require => false
  gem "guard-bundler", :require => false
  gem "guard-rspec",   :require => false
  gem "guard-yard",    :require => false
  gem "guard-shell",   :require => false
  gem 'libnotify',     :require => false
  gem 'growl',         :require => false
  gem 'rb-inotify',    :require => false
  gem 'rb-fsevent',    :require => false
  gem 'rb-fchange',    :require => false
end

group :test do
  gem "rspec", "~> 2.13.0"
  gem "rspec-core", "~> 2.13.0"
  gem "rspec-expectations", "~> 2.13.0"
  gem "rspec-mocks", "~> 2.13.0"
  gem "rake", "~> 10.1.0"
  gem "webmock", "~> 1.13.0"
end

group :extended_testing do
  gem "childprocess", "~> 0.3.9"
  gem 'simplecov', "~> 0.7.1", :require => false
  gem 'simplecov-rcov', "~> 0.2.3", :require => false
end


