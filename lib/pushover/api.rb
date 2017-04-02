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
    # reason:  anything else would add bloat, might change my mind later.
    def post(hash)
      hash
    end

    # rubocop: enable Metrics/ParameterLists

    module_function :post
    module_function :endpoints
  end
end
