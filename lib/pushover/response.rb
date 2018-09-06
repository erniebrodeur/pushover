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

    def process; end

    def process_body; end

    def process_headers; end
  end
end
