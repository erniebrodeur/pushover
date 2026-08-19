require 'oj'
require 'excon'

require 'pushover/client'
require 'pushover/glances'
require 'pushover/limits'
require 'pushover/message_encryption'
require 'pushover/message_validator'
require 'pushover/messages'
require 'pushover/message'
require 'pushover/response'
require 'pushover/receipts'
require 'pushover/receipt'
require 'pushover/sounds'
require 'pushover/users'
require 'pushover/version'

# pushover interface for ruby
module Pushover
  # headers to include in every request.
  HEADERS = { 'Content-Type' => 'application/json', 'User-Agent' => "pushover (ruby gem) v#{VERSION}" }.freeze
  # excon connection to use for every request.
  Excon = Excon.new('https://api.pushover.net', headers: HEADERS)
end
