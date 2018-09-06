# Pushover interface
module Pushover
  class Message
    include Creatable

    attribute name: 'attachment'
    attribute name: 'device', kind_of: String
    attribute name: 'html', kind_of: TrueClass
    attribute name: 'message', kind_of: String
    attribute name: 'priority', kind_of: String
    attribute name: 'sound', kind_of: String
    attribute name: 'timestamp', kind_of: Numeric
    attribute name: 'title', kind_of: String
    attribute name: 'token', kind_of: String
    attribute name: 'response', kind_of: Pushover::Response
    attribute name: 'url_title', kind_of: String
    attribute name: 'url', kind_of: String
    attribute name: 'user', kind_of: String

    def initialize
      @timestamp = Time.now.to_i
    end

    def push
      raise ArgumentError, 'user is a required parameter' unless user
      raise ArgumentError, 'token is a required parameter' unless token
      raise ArgumentError, 'message is a required parameter' unless message

      body = {}

      attributes.each { |e| body.store e[:name], instance_variable_get("@#{e[:name]}") if instance_variable_get("@#{e[:name]}") }

      excon_response = Api.connection.post path: '1/messages.json', body: Oj.dump(body)
      response = Response.create original: excon_response
      response.process
      self
    end
  end
end
