module Pushover
  # Groups provides operations for the Delivery Groups API.
  class Groups
    def initialize(client)
      @client = client
    end

    # Create an empty delivery group.
    # @return [Response] the Pushover API response
    def create(name:)
      validate_name!(name)

      response = @client.connection.post(
        path: '/1/groups.json',
        body: Oj.dump('token' => @client.token, 'name' => name)
      )
      Response.create_from_excon_response(response)
    end

    private

    def validate_name!(name)
      raise ArgumentError, 'name must be supplied' if name.nil? || name == ''
      raise ArgumentError, 'name must be a String' unless name.is_a?(String)
    end
  end
end
