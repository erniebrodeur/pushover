require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :release do
	`rake build`
	`gem inabox`
	exit
end

require "bundler/gem_tasks"
