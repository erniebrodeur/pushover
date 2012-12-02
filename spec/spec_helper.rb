if ENV["COVERAGE"] == 'true'
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start do
    add_filter "/spec/"
  end
end
require 'webmock/rspec'

require 'pushover'

include Pushover

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

def setup_webmocks
  WebMock.reset!
  good_result = '{"status":1}'
  bad_token = '{"token":"invalid","errors":["application token is invalid"],"status":0}'
  bad_user = '{"user":"invalid","errors":["user identifier is invalid"],"status":0}'

  stub_http_request(:post, "https://api.pushover.net/1/messages.json").to_return(:status => 200,
  :headers => {}, :body => good_result).with(:body => hash_including({token:'good_token', user:'good_user'}))
  stub_http_request(:post, "https://api.pushover.net/1/messages.json").to_return(:status => 200,
  :headers => {}, :body => bad_token).with(:body => hash_including({token:'bad_token', user:'good_user'}))
  stub_http_request(:post, "https://api.pushover.net/1/messages.json").to_return(:status => 200,
  :headers => {}, :body => bad_user).with(:body => hash_including({token:'good_token', user:'bad_user'}))
end



