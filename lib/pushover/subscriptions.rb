require 'pushover/users'

module Pushover
  # Subscriptions provides operations for the Subscription API.
  class Subscriptions
    def initialize(client)
      @client = client
    end

    # Migrate an existing user key to an application subscription.
    # @return [Response] the Pushover API response
    def migrate(subscription:, user:, device_name: nil, sound: nil)
      validate_subscription!(subscription)
      validate_user!(user)
      validate_device_name!(device_name) unless device_name.nil?
      validate_sound!(sound) unless sound.nil?

      body = { 'token' => @client.token, 'subscription' => subscription, 'user' => user }
      body['device_name'] = device_name unless device_name.nil?
      body['sound'] = sound unless sound.nil?

      response = @client.connection.post(path: '/1/subscriptions/migrate.json', body: Oj.dump(body))
      Response.create_from_excon_response(response)
    end

    private

    def validate_subscription!(subscription)
      raise ArgumentError, 'subscription must be supplied' if subscription.nil? || subscription == ''
      raise ArgumentError, 'subscription must be a String' unless subscription.is_a?(String)
    end

    def validate_user!(user)
      raise ArgumentError, 'user must be supplied' if user.nil? || user == ''
      raise ArgumentError, 'user must be 30 alphanumeric characters' unless user.is_a?(String) && user.match?(Users::USER_PATTERN)
    end

    def validate_device_name!(device_name)
      return if device_name.is_a?(String) && device_name.match?(Users::DEVICE_PATTERN)

      raise ArgumentError, 'device_name must be 1 to 25 letters, numbers, underscores, or hyphens'
    end

    def validate_sound!(sound)
      raise ArgumentError, 'sound must be a String' unless sound.is_a?(String)
    end
  end
end
