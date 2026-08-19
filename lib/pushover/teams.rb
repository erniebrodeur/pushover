module Pushover
  # Teams provides operations for the Pushover for Teams API.
  class Teams
    TEXT_FIELDS = %i[name password group].freeze
    FLAGS = %i[instant admin].freeze

    def initialize(client)
      @client = client
    end

    # Retrieve the team and its users and devices.
    # @return [Response] the Pushover API response
    def get
      response = @client.connection.get(
        path:  '/1/teams.json',
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end

    # Add a user or send an invitation to the team.
    # @return [Response] the Pushover API response
    def add_user(email:, **fields)
      validate_email!(email)
      validate_add_user_fields!(fields)

      body = { 'email' => email }.merge(fields.slice(*TEXT_FIELDS).compact.transform_keys(&:to_s))
      add_flags!(body, **fields.slice(*FLAGS))
      post_action('add_user', body)
    end

    # Revoke a pending team invitation.
    # @return [Response] the Pushover API response
    def revoke_invitation(email:)
      post_email_action('revoke_invitation', email)
    end

    # Remove a user from the team and its delivery groups.
    # @return [Response] the Pushover API response
    def remove_user(email:)
      post_email_action('remove_user', email)
    end

    private

    def post_email_action(action, email)
      validate_email!(email)
      post_action(action, 'email' => email)
    end

    def post_action(action, fields)
      body = { 'token' => @client.token }.merge(fields)
      response = @client.connection.post(
        path: "/1/teams/#{action}.json",
        body: Oj.dump(body)
      )
      Response.create_from_excon_response(response)
    end

    def add_flags!(body, **flags)
      flags.each do |field, value|
        next if value.nil?

        validate_flag!(field, value)
        body[field.to_s] = 'true' if value
      end
    end

    def validate_email!(email)
      return if email.is_a?(String) && !email.strip.empty?

      raise ArgumentError, 'email must be a nonblank String'
    end

    def validate_text_fields!(fields)
      invalid = TEXT_FIELDS.find { |field| fields.key?(field) && !fields[field].is_a?(String) }
      raise ArgumentError, "#{invalid} must be a String" if invalid
    end

    def validate_add_user_fields!(fields)
      unknown = fields.keys - (TEXT_FIELDS + FLAGS)
      raise ArgumentError, "unsupported team user parameter: #{unknown.first}" unless unknown.empty?

      validate_text_fields!(fields.compact)
    end

    def validate_flag!(field, value)
      return if [true, false].include?(value)

      raise ArgumentError, "#{field} must be true or false"
    end
  end
end
