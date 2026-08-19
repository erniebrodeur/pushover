module Pushover
  # Deprecated compatibility interface for sending messages.
  class Message
    ATTRIBUTES = %i[
      token user message attachment device title url url_title priority sound timestamp expire retry callback
    ].freeze
    private_constant :ATTRIBUTES

    attr_accessor(*ATTRIBUTES)

    def initialize(attributes = {}, **keywords)
      raise ArgumentError, 'attributes must be supplied as a Hash' unless attributes.is_a?(Hash)

      values = attributes.merge(keywords).transform_keys(&:to_sym)
      unknown = values.keys - ATTRIBUTES
      raise ArgumentError, "unknown keywords: #{unknown.join(', ')}" unless unknown.empty?

      values.each { |attribute, value| public_send("#{attribute}=", value) }
    end

    # Send the configured message through the shared client.
    # @return [Response] the Pushover API response
    def push
      require 'pushover' unless defined?(Pushover::Excon)
      warn 'Pushover::Message#push is deprecated; use Pushover::Client.new(token: ...).messages.create(...)', uplevel: 1
      %i[token user message].each { |param| raise "#{param} must be supplied" unless public_send(param) }
      raise ArgumentError, 'raw attachment is unsupported; use attachment_base64 and attachment_type with Pushover::Client#messages.create' unless attachment.nil?

      params = ATTRIBUTES.to_h { |attribute| [attribute, public_send(attribute)] }
                         .except(:token, :attachment)
                         .compact
      Client.new(token: token).messages.create(**params)
    end
  end
end
