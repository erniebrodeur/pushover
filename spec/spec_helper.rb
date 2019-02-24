require 'excon'
require 'pry'
require 'simplecov'
require 'simplecov-console'

Excon.defaults[:mock] = true

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "tmp/examples.txt"
end

RSpec::Matchers.alias_matcher :return_a_kind_of, :be_a_kind_of

SimpleCov.start do
  add_filter "/spec/"
end

require 'pushover'
