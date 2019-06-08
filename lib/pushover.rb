require 'oj'
require 'excon'

require 'pushover/message'
require 'pushover/response'
require 'pushover/receipt'
require 'pushover/version'

# pushover interface for ruby
module Pushover
  # headers to include in every request.
  HEADERS = { 'Content-Type' => 'application/json', 'User-Agent' => "pushover (ruby gem) v#{VERSION}" }.freeze
  # excon connection to use for every request.
  Excon = Excon.new('https://api.pushover.net', headers: HEADERS).freeze
end
