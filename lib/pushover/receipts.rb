require 'uri'

module Pushover
  # Receipts provides operations for the Receipt API.
  class Receipts
    RECEIPT_PATTERN = /\A[A-Za-z0-9]{30}\z/

    def initialize(client)
      @client = client
    end

    # Retrieve the current status of an emergency message receipt.
    # @return [Response] the Pushover API response
    def get(receipt:)
      validate_receipt!(receipt)

      response = @client.connection.get(
        path:  "/1/receipts/#{receipt}.json",
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end

    # Cancel future retries for an emergency message receipt.
    # @return [Response] the Pushover API response
    def cancel(receipt:)
      validate_receipt!(receipt)

      response = @client.connection.post(
        path: "/1/receipts/#{receipt}/cancel.json",
        body: Oj.dump(token: @client.token)
      )
      Response.create_from_excon_response(response)
    end

    # Cancel future retries for all emergency messages with a tag.
    # @return [Response] the Pushover API response
    def cancel_by_tag(tag:)
      validate_tag!(tag)
      encoded_tag = URI.encode_uri_component(tag)

      response = @client.connection.post(
        path: "/1/receipts/cancel_by_tag/#{encoded_tag}.json",
        body: Oj.dump('token' => @client.token)
      )
      Response.create_from_excon_response(response)
    end

    private

    def validate_receipt!(receipt)
      raise ArgumentError, 'receipt must be supplied' unless receipt.is_a?(String) && !receipt.empty?
      raise ArgumentError, 'receipt must be 30 alphanumeric characters' unless receipt.match?(RECEIPT_PATTERN)
    end

    def validate_tag!(tag)
      raise ArgumentError, 'tag must be supplied' unless tag.is_a?(String) && !tag.empty?
    end
  end
end
