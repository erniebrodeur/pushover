require 'pushover/users'

module Pushover
  # Glances provides operations for the Glances API.
  class Glances
    DATA_FIELDS = %i[title text subtext count percent].freeze
    SUPPORTED_FIELDS = ([:device] + DATA_FIELDS).freeze
    TEXT_FIELDS = %i[title text subtext].freeze

    def initialize(client)
      @client = client
    end

    # Update one or more fields shown on a user's registered widgets.
    # @return [Response] the Pushover API response
    def update(user:, **params)
      params = params.compact
      validate_supported_fields!(params)
      validate_user!(user)
      validate_data_fields!(params)
      validate_device!(params)
      validate_text_fields!(params)
      validate_count!(params)
      validate_percent!(params)

      body = { 'token' => @client.token, 'user' => user }.merge(params.transform_keys(&:to_s))
      response = @client.connection.post(path: '/1/glances.json', body: Oj.dump(body))
      Response.create_from_excon_response(response)
    end

    private

    def validate_supported_fields!(params)
      unknown = params.keys - SUPPORTED_FIELDS
      raise ArgumentError, "unsupported glance parameter: #{unknown.first}" unless unknown.empty?
    end

    def validate_user!(user)
      raise ArgumentError, 'user must be supplied' if user.nil? || user == ''
      raise ArgumentError, 'user must be 30 alphanumeric characters' unless user.is_a?(String) && user.match?(Users::USER_PATTERN)
    end

    def validate_data_fields!(params)
      return if DATA_FIELDS.any? { |field| params.key?(field) }

      raise ArgumentError, 'at least one glance data field must be supplied'
    end

    def validate_device!(params)
      return unless params.key?(:device)

      device = params[:device]
      return if device == '' || (device.is_a?(String) && device.match?(Users::DEVICE_PATTERN))

      raise ArgumentError, 'device must be blank or 1 to 25 letters, numbers, underscores, or hyphens'
    end

    def validate_text_fields!(params)
      TEXT_FIELDS.each do |field|
        next unless params.key?(field)

        value = params[field]
        raise ArgumentError, "#{field} must be a String" unless value.is_a?(String)
        raise ArgumentError, "#{field} must be at most 100 characters" if value.length > 100
      end
    end

    def validate_count!(params)
      return unless params.key?(:count)

      count = params[:count]
      return if count == '' || count.is_a?(Integer)

      raise ArgumentError, 'count must be an Integer or blank'
    end

    def validate_percent!(params)
      return unless params.key?(:percent)

      percent = params[:percent]
      return if percent == '' || (percent.is_a?(Integer) && percent.between?(0, 100))

      raise ArgumentError, 'percent must be an Integer from 0 to 100 or blank'
    end
  end
end
