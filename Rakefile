require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--cache-root', 'tmp/rubocop_cache']
end

desc 'Run all continuous integration checks'
task ci: %i[spec rubocop]

task default: :ci
