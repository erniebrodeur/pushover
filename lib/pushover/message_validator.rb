require 'base64'
require 'uri'

module Pushover
  # MessageValidator enforces deterministic Message API request rules.
  class MessageValidator
    ATTACHMENT_LIMIT = 5_242_880
    CHARACTER_LIMITS = { message: 1024, title: 250, url: 512, url_title: 100 }.freeze
    EMERGENCY_FIELDS = %i[retry expire callback tags].freeze
    FLAGS = %i[html monospace].freeze
    PRIORITIES = [-2, -1, 0, 1, 2].freeze
    STRING_FIELDS = %i[
      user message attachment_base64 attachment_type device sound title url url_title callback tags
    ].freeze
    SUPPORTED_FIELDS = (STRING_FIELDS + FLAGS + %i[priority timestamp ttl retry expire encryption_key]).freeze

    def initialize(**params)
      @params = params.compact
    end

    def validate
      validate_supported_fields
      validate_required_fields
      validate_string_fields
      validate_character_limits
      validate_users
      validate_devices
      validate_flags
      validate_numbers
      validate_emergency_fields
      validate_callback
      validate_attachment
      validate_encryption_key
      @params
    end

    private

    def validate_supported_fields
      unknown = @params.keys - SUPPORTED_FIELDS
      raise ArgumentError, "unsupported message parameter: #{unknown.first}" unless unknown.empty?
    end

    def validate_required_fields
      %i[user message].each do |field|
        value = @params[field]
        raise ArgumentError, "#{field} must be supplied" unless value.is_a?(String) && !value.empty?
      end
    end

    def validate_string_fields
      STRING_FIELDS.each do |field|
        next unless @params.key?(field)

        raise ArgumentError, "#{field} must be a String" unless @params[field].is_a?(String)
      end
    end

    def validate_character_limits
      CHARACTER_LIMITS.each do |field, maximum|
        next unless @params.key?(field)
        next if @params[field].length <= maximum

        raise ArgumentError, "#{field} must be at most #{maximum} characters"
      end
    end

    def validate_users
      raise ArgumentError, 'user may contain at most 50 users' if @params[:user].split(',', -1).length > 50
    end

    def validate_devices
      return unless @params.key?(:device)

      valid = @params[:device].split(',', -1).all? { |device| device.match?(/\A[A-Za-z0-9_-]{1,25}\z/) }
      raise ArgumentError, 'device contains an invalid name' unless valid
    end

    def validate_flags
      FLAGS.each do |field|
        next unless @params.key?(field)

        value = @params[field]
        raise ArgumentError, "#{field} must be true, false, 1, or 0" unless [true, false, 1, 0].include?(value)

        @params[field] = [true, 1].include?(value) ? 1 : 0
      end

      return unless @params[:html] == 1 && @params[:monospace] == 1

      raise ArgumentError, 'html and monospace cannot both be enabled'
    end

    def validate_numbers
      validate_allowed_integer(:priority, PRIORITIES)
      validate_minimum_integer(:timestamp, 0)
      validate_minimum_integer(:ttl, 1, 'ttl must be a positive integer')
      validate_minimum_integer(:retry, 30, 'retry must be at least 30 seconds')
      validate_minimum_integer(:expire, 1)
    end

    def validate_allowed_integer(field, allowed)
      return unless @params.key?(field)

      value = @params[field]
      return if value.is_a?(Integer) && allowed.include?(value)

      raise ArgumentError, "#{field} must be one of #{allowed.join(', ')}"
    end

    def validate_minimum_integer(field, minimum, message = nil)
      return unless @params.key?(field)
      return if @params[field].is_a?(Integer) && @params[field] >= minimum

      raise ArgumentError, message || "#{field} must be at least #{minimum}"
    end

    def validate_emergency_fields
      if @params[:priority] == 2
        raise ArgumentError, 'retry and expire must be supplied with priority 2' unless @params.key?(:retry) && @params.key?(:expire)
        raise ArgumentError, 'expire must be at most 10800 seconds' if @params[:expire] > 10_800

        return
      end

      field = EMERGENCY_FIELDS.find { |name| @params.key?(name) }
      raise ArgumentError, "#{field} is only valid with priority 2" if field
    end

    def validate_attachment
      data = @params[:attachment_base64]
      type = @params[:attachment_type]
      return unless data || type

      raise ArgumentError, 'attachment_base64 must be supplied with attachment_type' unless data
      raise ArgumentError, 'attachment_type must be supplied with attachment_base64' unless type
      raise ArgumentError, 'attachment_type must be an image MIME type' unless type.match?(/\Aimage\/[A-Za-z0-9.+-]+\z/)

      decoded = decode_attachment(data)
      raise ArgumentError, 'attachment must not exceed 5242880 bytes' if decoded.bytesize > ATTACHMENT_LIMIT
    end

    def validate_callback
      return unless @params.key?(:callback)

      callback = URI.parse(@params[:callback])
      return if callback.is_a?(URI::HTTP) && callback.host

      raise ArgumentError, 'callback must be an HTTP or HTTPS URL'
    rescue URI::InvalidURIError
      raise ArgumentError, 'callback must be an HTTP or HTTPS URL'
    end

    def decode_attachment(data)
      Base64.strict_decode64(data)
    rescue ArgumentError
      raise ArgumentError, 'attachment_base64 must be valid Base64'
    end

    def validate_encryption_key
      return unless @params.key?(:encryption_key)
      return if @params[:encryption_key].is_a?(String) && @params[:encryption_key].match?(/\A[0-9a-fA-F]{64}\z/)

      raise ArgumentError, 'encryption_key must be 64 hexadecimal characters'
    end
  end
end
