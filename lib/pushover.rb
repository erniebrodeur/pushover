require 'oj'
require 'creatable'
require 'excon'

# pushover interface for ruby
module Pushover
  HEADERS = { 'Content-Type' => 'application/json', 'User-Agent' => "pushover (ruby gem) v#{VERSION}" }.freeze
  Excon = Excon.new('https://api.pushover.net', headers: HEADERS).freeze

  Message = Struct.new(:token, :key, :message, :attachment, :device, :title, :url, :url_title, :priority, :sound, :timestamp, keyword_init: true) do
    def push
      %i[token key message].each { |param| raise "#{param} must be supplied" unless send param }

      Response.create_from_excon_response Excon.post(path: '1/message.json', query: to_h)
    end
  end

  Response = Struct.new(:status, :request, :errors, :receipt, :headers, keyword_init: true) do
    # Limits.define_method(:to_s) { "requests #{remaining} of #{limit}, reset on #{Time.at(reset.to_f)}" }
    # Results.define_method(:to_s) { "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}" }

    def limits
      output = [excon_response.headers['X-Limit-App-Limit'], excon_response.headers['X-Limit-App-Remaining'], excon_response.headers['X-Limit-App-Reset']]
      output.define_singleton_method(:to_s) { "requests #{remaining} of #{limit}, reset on #{Time.at(reset.to_f)}" }
      output
    end

    def self.create_from_excon_response(excon_response)
      binding.pry
      Response.new(*Oj.load(excon_response[:body]).merge(headers: excon_response.headers))
    end

    def to_s
      "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}"
    end
  end
end
