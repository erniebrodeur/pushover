require "net/https"
require "yajl"
require 'bini'
require 'bini/config'
require 'bini/optparser'

require "pushover/version"
require "pushover/app"
require "pushover/user"
# The primary pushover namespace.
module Pushover
  # lets save our config to it's own dir, just because.
  Bini.config.file = "#{Dir.home}/.config/pushover/credentials.yaml"
  Bini.config.load

  extend self

  # [String] The api key to be used for the notifcation.
  attr_accessor :token
  # [String] of the user token currently being used.
  attr_accessor :user
  # [String] message the message to be sent.
  attr_accessor :message
  # [optional,String] Title of the message.
  attr_accessor :title
  # [optional,String] device to recieve the message.
  attr_accessor :device
  # [optional,String, Fixnum] time a time stamp im one of three forms (epoch, strfmt, rails)
  attr_accessor :time


  def priority=(level)
    if level.class == String
      if level =~ /^[lL]/
        puts "called #{level}"
        @priority = -1
      elsif level =~ /^[nN]/
        @priority = 0
      elsif level =~ /^[hH]/
        @priority = 1
      end
    elsif level.class == Fixnum
      @priority = level
    else
      @priority = 0
    end
  end

  def priority
    @priority ||= 0
  end

  # push a message to  pushover, must supply all variables.
  # @param [String] message The message to be sent
  # @param [optional, String] title The title of the message
  # @param [optional, Fixnum] priority of the message to be sent, from -1 to 1.
  # @param [optional, String] device The specific device to be notified.
  # @param [optional, String] app api key.
  # @param [optional, String] user the user token.
  # @return [String] the response from pushover.net, in json.
  def notification(tokens={})
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(params.merge tokens)
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

  # Adds a rails style configure method
  def configure
    yield self
    parameters
  end

  # List available parameters and values in those params
  def parameters
    h = {}
    keys.each { |k| h[k.to_sym] = Pushover.instance_variable_get("@#{k}") }
    return h
  end
  alias_method :params, :parameters

  # Returns true or false if all parameters are set.
  def parameters?
    parameters.values.all?
  end

  # Clear all the currently set parameters
  def clear
    keys.each do |k|
      Pushover.instance_variable_set("@#{k}", nil)
    end
  end

  # A [Array] of keys available in Pushover.
  def keys
    keys ||= [:token, :user, :message, :title, :priority, :device]
  end
end
