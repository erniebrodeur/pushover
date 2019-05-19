module Pushover
  Message = Struct.new(:token, :user, :message, :attachment, :device, :title, :url, :url_title, :priority, :sound, :timestamp, :expire, :retry, :callback, keyword_init: true) do
    def push
      %i[token user message].each { |param| raise "#{param} must be supplied" unless send param }

      Response.create_from_excon_response Excon.post(path: '1/messages.json', query: to_h)
    end
  end
end
