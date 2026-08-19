module Pushover
  # Deprecated compatibility interface for retrieving receipts.
  class Receipt
    ATTRIBUTES = %i[receipt token].freeze
    private_constant :ATTRIBUTES

    attr_accessor(*ATTRIBUTES)

    def initialize(attributes = {}, **keywords)
      raise ArgumentError, 'attributes must be supplied as a Hash' unless attributes.is_a?(Hash)

      values = attributes.merge(keywords).transform_keys(&:to_sym)
      unknown = values.keys - ATTRIBUTES
      raise ArgumentError, "unknown keywords: #{unknown.join(', ')}" unless unknown.empty?

      values.each { |attribute, value| public_send("#{attribute}=", value) }
    end

    # Retrieve the configured receipt through the shared client.
    # @return [Response] the Pushover API response
    def get
      require 'pushover' unless defined?(Pushover::Excon)
      warn 'Pushover::Receipt#get is deprecated; use Pushover::Client.new(token: ...).receipts.get(receipt: ...)', uplevel: 1
      %i[receipt token].each { |param| raise "#{param} must be supplied" unless public_send(param) }

      Client.new(token: token).receipts.get(receipt: receipt)
    end
  end
end
