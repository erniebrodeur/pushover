module Pushover
  # Response encapsulates the response back from pushover.
  Response = Struct.new(:status, :request, :errors, :receipt, :headers, :attributes, keyword_init: true) do
    def limits
      return '' unless headers.include? 'X-Limit-App-Limit'

      output = [headers['X-Limit-App-Remaining'], headers['X-Limit-App-Limit'], headers['X-Limit-App-Reset']]
      output.define_singleton_method(:to_s) { "requests #{self[0]} of #{self[1]}, reset on #{Time.at(self[2].to_f)}" }
      output
    end

    def self.create_from_excon_response(excon_response)
      json = Oj.load excon_response[:body]
      values = json.select { |k, _v| members.include? k.to_sym }
      attributes = json.reject { |k, _v| members.include? k.to_sym }

      Response.new values.merge(headers: excon_response.headers, attributes: attributes)
    end

    def to_s
      "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}"
    end
  end
end
