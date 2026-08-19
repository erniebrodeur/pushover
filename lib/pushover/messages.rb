module Pushover
  # Messages provides operations for the Message API.
  class Messages
    def initialize(client)
      @client = client
    end

    # Create and send a message.
    # @return [Response] the Pushover API response
    def create(user:, message:, **)
      params = MessageValidator.new(user: user, message: message, **).validate
      encryption_key = params.delete(:encryption_key)
      params = MessageEncryption.new(encryption_key).encrypt(params) if encryption_key
      body = { 'token' => @client.token }.merge(params.transform_keys(&:to_s))

      response = @client.connection.post(path: '/1/messages.json', body: Oj.dump(body))
      Response.create_from_excon_response(response)
    end
  end
end
