module Pushover
  # Response encapsulates the response back from pushover.
  # Class to wrap the user and basic functions related to it.
  # @attribute status
  #   @return [Numeric] status of the response
  # @attribute request
  #   @return [String] request is a UUID representing the specific call
  # @attribute errors
  #   @return [Array] errors includes any errors made
  # @attribute receipt
  #   @return [String] receipt returns a receipt if requested
  # @attribute headers
  #   @return [Hash] headers is the headers returned from the call.
  # @attribute attributes
  #   @return [String] any extra k/v pairs from the server.
  Response = Struct.new(:status, :request, :errors, :receipt, :headers, :attributes, keyword_init: true) do
    # New response object, from an excon_response
    #   @return [Response] populated response object
    def self.create_from_excon_response(excon_response)
      json = Oj.load excon_response[:body]
      values = {}
      attributes = {}
      json.each { |k, v| members.include?(k.to_sym) ? values.store(k, v) : attributes.store(k, v) }

      Response.new values.merge(headers: excon_response.headers, attributes: attributes)
    end

    # purty.
    def to_s
      "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}"
    end

    private

    # :nocov:
    # Application limits
    # @return [Array] 0: Remaining Calls, 1: Total Limit, 2: Limit Reset
    def limits
      return '' unless headers.include? 'X-Limit-App-Limit'

      output = [headers['X-Limit-App-Remaining'], headers['X-Limit-App-Limit'], headers['X-Limit-App-Reset']]
      output.define_singleton_method(:to_s) { "requests #{self[0]} of #{self[1]}, reset on #{Time.at(self[2].to_f)}" }
      output
    end
  end
end
