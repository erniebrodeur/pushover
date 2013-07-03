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
Bini.long_name = 'pushover'

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
  sounds = '{"sounds":{"pushover":"Pushover (default)","bike":"Bike","bugle":"Bugle","cashregister":"Cash Register","classical":"Classical","cosmic":"Cosmic","falling":"Falling","gamelan":"Gamelan","incoming":"Incoming","intermission":"Intermission","magic":"Magic","mechanical":"Mechanical","pianobar":"Piano Bar","siren":"Siren","spacealarm":"Space Alarm","tugboat":"Tug Boat","alien":"Alien Alarm (long)","climb":"Climb (long)","persistent":"Persistent (long)","echo":"Pushover Echo (long)","updown":"Up Down (long)","none":"None (silent)"},"status":1,"request":"14ef413f6a3bf74efee3e140efe63df9"}'

  stub_request(:post, "https://api.pushover.net/1/messages.json").
    with(body:hash_including(token:'good_token', user:'good_user')).
    to_return(body:good_result, code:200)
  stub_request(:post, "https://api.pushover.net/1/messages.json").
    with(body:hash_including(token:'bad_token')).
    to_return(body:bad_token, code:400)
  stub_request(:post, "https://api.pushover.net/1/messages.json").
    with(body:hash_including(user:'bad_user')).
    to_return(body:bad_user, code:400)
  stub_request(:get, "https://api.pushover.net/1/sounds.json").
    to_return(body:sounds, code:200)
end
