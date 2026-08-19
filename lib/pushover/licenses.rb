require 'pushover/users'

module Pushover
  # Licenses provides operations for the Licensing API.
  class Licenses
    OPERATING_SYSTEMS = ['Android', 'iOS', 'Desktop'].freeze

    def initialize(client)
      @client = client
    end

    # Retrieve the application's available prepaid license credits.
    # @return [Response] the Pushover API response
    def get
      response = @client.connection.get(
        path:  '/1/licenses.json',
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end

    # Permanently assign one prepaid license credit to a user or e-mail address.
    # @return [Response] the Pushover API response
    def assign(user: nil, email: nil, os: nil)
      validate_recipient!(user, email)
      validate_os!(os) unless os.nil?

      body = { 'token' => @client.token }
      body['user'] = user unless user.nil?
      body['email'] = email unless email.nil?
      body['os'] = os unless os.nil?

      response = @client.connection.post(
        path:       '/1/licenses/assign.json',
        body:       Oj.dump(body),
        idempotent: false
      )
      Response.create_from_excon_response(response)
    end

    private

    def validate_recipient!(user, email)
      raise ArgumentError, 'user or email must be supplied' if user.nil? && email.nil?

      validate_user!(user) unless user.nil?
      validate_email!(email) unless email.nil?
    end

    def validate_user!(user)
      raise ArgumentError, 'user must be supplied' if user == ''
      raise ArgumentError, 'user must be 30 alphanumeric characters' unless user.is_a?(String) && user.match?(Users::USER_PATTERN)
    end

    def validate_email!(email)
      return if email.is_a?(String) && !email.strip.empty?

      raise ArgumentError, 'email must be a nonblank String'
    end

    def validate_os!(os)
      return if os == '' || OPERATING_SYSTEMS.include?(os)

      raise ArgumentError, 'os must be blank, Android, iOS, or Desktop'
    end
  end
end
