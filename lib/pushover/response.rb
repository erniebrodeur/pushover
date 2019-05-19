module Pushover
  Response = Struct.new(:status, :request, :errors, :receipt, :headers, keyword_init: true) do
    def limits
      return '' unless headers.include? 'X-Limit-App-Limit'

      output = [headers['X-Limit-App-Remaining'], headers['X-Limit-App-Limit'], headers['X-Limit-App-Reset']]
      output.define_singleton_method(:to_s) { "requests #{self[0]} of #{self[1]}, reset on #{Time.at(self[2].to_f)}" }
      output
    end

    def self.create_from_excon_response(excon_response)
      Response.new(Oj.load(excon_response[:body]).merge('headers' => excon_response.headers))
    end

    def to_s
      "#{errors ? 'errors: ' + errors.join("\n") : 'status: ok'}, #{limits}"
    end
  end
end
