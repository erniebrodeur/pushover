module Pushover
  # Sounds provides operations for the Sounds API.
  class Sounds
    def initialize(client)
      @client = client
    end

    # Retrieve built-in and application-account custom sounds.
    # @return [Response] the Pushover API response
    def get
      response = @client.connection.get(
        path:  '/1/sounds.json',
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end
  end
end
