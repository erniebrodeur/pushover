require "net/https"
require "yajl"
require 'time'
require 'bini'
require 'bini/config'
require 'bini/optparser'
require 'open-uri'

require "pushover/version"
require "pushover/app"
require "pushover/user"
# The primary pushover namespace.
module Pushover
  # lets save our config to it's own dir, just because.
  Bini::Config.file = "#{Dir.home}/.config/pushover/credentials.yaml"
  Bini::Config.load

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
  attr_accessor :url
  attr_accessor :url_title
  # [optional,String, Fixnum] time a time stamp im one of three forms (epoch, strfmt, rails)
  attr_reader   :timestamp
  attr_reader   :priority
  def priority=(level)
    @priority = priority_magic level
  end

  # Stdlib time, seems to take a shitload of options.
  # rfc822: Tue, 14 Nov 2000 14:55:07 -0500
  # xml: 1979-08-13T06:30:00.313UTC
  # Time.parse 'Aug 13, 1979 6:30'
  # Time.parse '1979/08/13, 6:30:50 UTC'
  def timestamp=(time_string)
    @timestamp = timestamp_magic time_string
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
    tokens[:timestamp] = timestamp_magic tokens[:timestamp] if tokens[:timestamp]
    tokens[:priority]  = priority_magic tokens[:priority] if tokens[:priority]

    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path, {'User-Agent' => "Ruby pushover gem: #{Pushover::VERSION}"})
    req.set_form_data(params.merge(tokens).select {|k,v| v != nil})
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
    Pushover.instance_methods.select do |m|
      m =~ /=$/
    end.map do |m|
      m[0..-2]
    end
  end

  def sounds
    cache_file = "#{Bini.cache_dir}/sounds.json"
    sounds = {}
    unless File.exists?(cache_file) && File.stat(cache_file).mtime > Time.at(Time.now.day - 1)
      content = open("https://api.pushover.net/1/sounds.json?token=#{Pushover::App.current_app}").read
      FileUtils.mkdir_p Bini.cache_dir
      f = open(cache_file, 'w')
      f.write content
      f.flush
      f.close
    end

    sounds = Yajl.load open(cache_file).read
    sounds["sounds"]
  end

  private

  def timestamp_magic(time_string)
    if time_string.class == String
      begin
        return Time.parse(time_string).to_i
      rescue ArgumentError
        return time_string.to_i
      end
    elsif
      time_string.class == Fixnum
      return time_string
    end
  end

  def priority_magic(level)
    if level.class == String
      if level =~ /^[lL]/
        return -1
      elsif level =~ /^[hH]/
        return 1
      else
        return 0
      end
    elsif level.class == Fixnum
      return level
    end
  end
end

