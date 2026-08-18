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
      raise ArgumentError, 'receipt must be supplied' unless receipt.is_a?(String) && !receipt.empty?
      raise ArgumentError, 'receipt must be 30 alphanumeric characters' unless receipt.match?(RECEIPT_PATTERN)

      response = @client.connection.get(
        path:  "/1/receipts/#{receipt}.json",
        query: { token: @client.token }
      )
      Response.create_from_excon_response(response)
    end
  end
end
