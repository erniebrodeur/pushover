module Pushover
  # Limits provides operations for the account and team usage limits API.
  class Limits
    def initialize(client)
      @client = client
    end

    # Retrieve the current monthly message usage limits.
    # @return [Response] the Pushover API response
    def get
      response = @client.connection.get(
        path:  '/1/apps/limits.json',
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end
  end
end
