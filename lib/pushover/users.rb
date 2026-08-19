module Pushover
  # Users provides operations for the User/Group Validation API.
  class Users
    USER_PATTERN = /\A[A-Za-z0-9]{30}\z/
    DEVICE_PATTERN = /\A[A-Za-z0-9_-]{1,25}\z/

    def initialize(client)
      @client = client
    end

    # Validate a user or group identifier and optional device.
    # @return [Response] the Pushover API response
    def validate(user:, device: nil)
      validate_user!(user)
      validate_device!(device) unless device.nil?

      body = { 'token' => @client.token, 'user' => user }
      body['device'] = device if device

      response = @client.connection.post(path: '/1/users/validate.json', body: Oj.dump(body))
      Response.create_from_excon_response(response)
    end

    private

    def validate_user!(user)
      raise ArgumentError, 'user must be supplied' if user.nil? || user == ''
      raise ArgumentError, 'user must be 30 alphanumeric characters' unless user.is_a?(String) && user.match?(USER_PATTERN)
    end

    def validate_device!(device)
      return if device.is_a?(String) && device.match?(DEVICE_PATTERN)

      raise ArgumentError, 'device must be 1 to 25 letters, numbers, underscores, or hyphens'
    end
  end
end
