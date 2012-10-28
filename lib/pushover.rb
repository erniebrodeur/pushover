require "net/https"
require "yajl"

require "pushover/version"
require "pushover/app"
require "pushover/user"
require "pushover/config"
require "pushover/optparser"

# The primary pushover namespace.
module Pushover

  extend self

  # [String] The api key to be used for the notifcation.
  attr_accessor :token
  # [String] of the user token currently being used.
  attr_accessor :user
  # [String] message the message to be sent.
  attr_accessor :message
  # [optional,String] Title of the message.
  attr_accessor :title
  # [optional,Fixnum] priority The priority of the message, from -1 to 1.
  attr_accessor :priority
  # [optional,String] device to recieve the message.
  attr_accessor :device

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
    @values = {}
    keys.each { |k| @values.merge! k => get_var("@#{k}") }
    @values
  end
  alias_method :params, :parameters

  # Returns true or false if all parameters are set.
  def parameters?
    parameters.values.all?
  end

  # A [Array] of keys available in Pushover.
  def keys
    keys ||= [:token, :user, :message, :title, :priority, :device]
  end

  private

  # Helper to clean up recursive method in #parameters
  def get_var(var)
    self.instance_variable_get(var)
  end

end
