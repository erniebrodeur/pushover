require 'pushover/users'

module Pushover
  # Groups provides operations for the Delivery Groups API.
  class Groups
    GROUP_PATTERN = /\A[A-Za-z0-9]{30}\z/

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

    # List delivery groups owned by the client's account or team.
    # @return [Response] the Pushover API response
    def list
      response = @client.connection.get(
        path:  '/1/groups.json',
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end

    # Retrieve a delivery group's name and users.
    # @return [Response] the Pushover API response
    def get(group:)
      validate_group!(group)

      response = @client.connection.get(
        path:  "/1/groups/#{group}.json",
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end

    # Add a user membership to a delivery group.
    # @return [Response] the Pushover API response
    def add_user(group:, user:, device: nil, memo: nil)
      validate_membership!(group, user, device)
      validate_memo!(memo) unless memo.nil?

      fields = membership_fields(user, device)
      fields['memo'] = memo unless memo.nil?
      post_group_action(group, 'add_user', fields)
    end

    # Remove a user's matching memberships from a delivery group.
    # @return [Response] the Pushover API response
    def remove_user(group:, user:, device: nil)
      post_user_action('remove_user', group:, user:, device:)
    end

    # Temporarily disable a user's matching group memberships.
    # @return [Response] the Pushover API response
    def disable_user(group:, user:, device: nil)
      post_user_action('disable_user', group:, user:, device:)
    end

    # Re-enable a user's matching group memberships.
    # @return [Response] the Pushover API response
    def enable_user(group:, user:, device: nil)
      post_user_action('enable_user', group:, user:, device:)
    end

    # Rename a delivery group.
    # @return [Response] the Pushover API response
    def rename(group:, name:)
      validate_group!(group)
      validate_name!(name)
      post_group_action(group, 'rename', 'name' => name)
    end

    private

    def post_user_action(action, group:, user:, device:)
      validate_membership!(group, user, device)
      post_group_action(group, action, membership_fields(user, device))
    end

    def post_group_action(group, action, fields)
      body = { 'token' => @client.token }.merge(fields)
      response = @client.connection.post(
        path: "/1/groups/#{group}/#{action}.json",
        body: Oj.dump(body)
      )
      Response.create_from_excon_response(response)
    end

    def membership_fields(user, device)
      fields = { 'user' => user }
      fields['device'] = device unless device.nil?
      fields
    end

    def validate_membership!(group, user, device)
      validate_group!(group)
      validate_user!(user)
      validate_device!(device) unless device.nil?
    end

    def validate_group!(group)
      raise ArgumentError, 'group must be supplied' if group.nil? || group == ''
      raise ArgumentError, 'group must be 30 alphanumeric characters' unless group.is_a?(String) && group.match?(GROUP_PATTERN)
    end

    def validate_user!(user)
      raise ArgumentError, 'user must be supplied' if user.nil? || user == ''
      raise ArgumentError, 'user must be 30 alphanumeric characters' unless user.is_a?(String) && user.match?(Users::USER_PATTERN)
    end

    def validate_device!(device)
      return if device == '' || (device.is_a?(String) && device.match?(Users::DEVICE_PATTERN))

      raise ArgumentError, 'device must be blank or 1 to 25 letters, numbers, underscores, or hyphens'
    end

    def validate_memo!(memo)
      raise ArgumentError, 'memo must be a String' unless memo.is_a?(String)
      raise ArgumentError, 'memo must be at most 200 characters' if memo.length > 200
    end

    def validate_name!(name)
      raise ArgumentError, 'name must be supplied' if name.nil? || name == ''
      raise ArgumentError, 'name must be a String' unless name.is_a?(String)
    end
  end
end
