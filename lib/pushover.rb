require 'oj'
require 'excon'

require 'pushover/version'
require 'pushover/message'
require 'pushover/response'
require 'pushover/receipt'

# pushover interface for ruby
module Pushover
  # headers to include in every request.
  HEADERS = { 'Content-Type' => 'application/json', 'User-Agent' => "pushover (ruby gem) v#{VERSION}" }.freeze
  # excon connection to use for every request.
  Excon = Excon.new('https://api.pushover.net', headers: HEADERS).freeze
end
