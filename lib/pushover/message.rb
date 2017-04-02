module Pushover
  # Message object
  class Message
    attr_accessor :token
    attr_accessor :user
    attr_accessor :device
    attr_accessor :timestamp
    attr_accessor :title
    attr_accessor :message
    attr_accessor :priority
    attr_accessor :url
    attr_accessor :url_title
    attr_accessor :sound

    def initialize
      @token = ''
      @user = ''
      @device = ''
      @title = ''
      @message = ''
      @priority = ''
      @url = ''
      @url_title = ''
      @sound = ''
      @timestamp = DateTime.now
    end
  end
end
