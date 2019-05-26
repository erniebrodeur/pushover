module Pushover
  # Message is a struct to send a message to pushover.
  # @!attribute [rw] token
  #   @return [String] application token
  # @!attribute [rw] user
  #   @return [String] user key
  # @!attribute [rw] message
  #   @return [String] message to transmit
  # @!attribute [rw] device
  #   @return [String] device to transmit too
  # @!attribute [rw] title
  #   @return [String] title of the message
  # @!attribute [rw] url
  #   @return [String] supplementary url
  # @!attribute [rw] url_title
  #   @return [String] title of the supplementary url
  # @!attribute [rw] priority
  #   @return [Numeric] numeric value for priority.
  # @!attribute [rw] sound
  #   @return [String] sound to play
  # @!attribute [rw] timestamp
  #   @return [Numeric] timestamp to expire, in epoch
  # @!attribute [rw] expire
  #   @return [Numeric] expire time until message expires
  # @!attribute [rw] retry
  #   @return [Numeric] how long to retry for, in seconds
  # @!attribute [rw] callback
  #   @return [String] callback url
  Message = Struct.new(:token, :user, :message, :attachment, :device, :title, :url, :url_title, :priority, :sound, :timestamp, :expire, :retry, :callback, keyword_init: true) do
    # push the configured message to pushover.
    #   @return [Response] response for the receipt request
    def push
      %i[token user message].each { |param| raise "#{param} must be supplied" unless send param }

      Response.create_from_excon_response Excon.post(path: '1/messages.json', query: to_h)
    end
  end
end
