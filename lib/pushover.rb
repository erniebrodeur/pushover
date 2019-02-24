require 'oj'
require 'creatable'
require 'excon'

# pushover interface for ruby
module Pushover
  module_function

  VERSION = 1.0

  Limits = Struct.new(:limit, :remaining, :reset)
  Limits.define_method(:to_s) { "requests #{remaining} of #{limit}, reset on #{Time.at(reset.to_f)}" }

  Results = Struct.new(:status, :request, :errors, :limits)
  Results.define_method(:to_s) { "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}" }

  def connection
    Excon.new('https://api.pushover.net', headers: {'Content-Type' => 'application/json', 'User-Agent'   => "pushover (ruby gem) v#{Pushover::VERSION}" })
  end

  def message(config)
    excon_response = connection.post path: "1/messages.json", query: config

    result = Oj.load excon_response[:body]

    Results[
      result["status"],
      result["request"],
      result.dig("errors"),
      Limits[excon_response.headers['X-Limit-App-Limit'], excon_response.headers['X-Limit-App-Remaining'], excon_response.headers['X-Limit-App-Reset']]
    ]
  end
end
