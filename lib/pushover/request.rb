module Pushover
  class Request
    include Creatable

    def push(endpoint, config = {})
      excon_response = Api.connection.post path: "1/#{endpoint}.json", query: config
      response = Response.create original: excon_response
      response.process
      @response = response
    end
  end
end
