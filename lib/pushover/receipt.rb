module Pushover
  # Receipt is a struct to interface with the receipt endpoint.
  # @!attribute [rw] receipt
  #   @return [String] id of the receipt to request
  # @!attribute [rw] token
  #   @return [String] application token to check for a receipt
  Receipt = Struct.new(:receipt, :token, keyword_init: true) do
    def initialize(*)
      super
      self.token ||= ENV['PUSHOVER_TOKEN']
    end

    # Call pushover and return a response.
    # @return [Response] response for the receipt request
    def get
      %i[receipt token].each { |param| raise "#{param} must be supplied" unless send param }

      Response.create_from_excon_response Excon.get(path: "1/receipts/#{receipt}.json", query: { token: token })
    end
  end
end
