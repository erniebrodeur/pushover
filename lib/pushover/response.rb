module Pushover
  class Response
    include Creatable

    attribute name: 'user', kind_of: String
    attribute name: 'errors', kind_of: Array
    attribute name: 'status', kind_of: Numeric
    attribute name: 'receipt', kind_of: String
    attribute name: 'request', kind_of: String
    attribute name: 'original', kind_of: String
    attribute name: 'limit', kind_of: String
    attribute name: 'remaining', kind_of: String
    attribute name: 'reset', kind_of: String

    def initialize
      @status = 0
      @errors = []
    end

    def process
      process_body
      process_headers
    end

    def process_body
      body = Oj.load original[:body]

      @status = body[:status]
      @request = body[:request]
      @receipt = body[:receipt] if body[:receipt]
      @errors = body[:errors] if body[:errors]
    end

    def process_headers
      @limit = original.headers['X-Limit-App-Limit']
      @remaining = original.headers['X-Limit-App-Remaining']
      @reset = original.headers['X-Limit-App-Reset']
    end
  end
end
