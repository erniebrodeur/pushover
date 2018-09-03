require 'creatable'
require 'excon'
require 'oj'

require 'pushover/response'

module Pushover
  # Api module
  module Api
    module_function

    def endpoints
      %i[messages sounds limits receipts validate]
    end

    def sounds
      %i[ pushover bike bugle cashregister classical cosmic falling gamelan incoming
          intermission magic mechanical pianobar siren spacealarm tugboat alien
          climb persistent echo updown none]
    end

    def connection
      Excon.new url
    end

    def initialize
      Excon.defaults[:headers]['Content-Type'] = 'application/json'
      Excon.defaults[:headers]['User-Agent'] = "pushover (ruby gem) v#{Pushover::VERSION}"
    end

    def url
      "https://api.pushover.net"
    end
  end
end
