require 'excon'
require 'simplecov'
Excon.defaults[:mock] = true

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "tmp/examples.txt"
end

RSpec::Matchers.alias_matcher :return_a_kind_of, :be_a_kind_of

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start { skip "/spec/" }

require 'pushover'
