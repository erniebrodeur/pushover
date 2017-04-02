require 'spec_helper'

module Pushover
  # Api module
  module Api
    def endpoints
      {
        messages: 'https://api.pushover.net/1/messages',
        sounds:   'https://api.pushover.net/1/sounds',
        limits:   'https://api.pushover.net/1/limits',
        receipts: 'https://api.pushover.net/1/receipts',
        validate: 'https://api.pushover.net/1/validate'
      }
    end

    def endpoint(endpoint); end

    module_function :endpoint
    module_function :endpoints
  end
end
