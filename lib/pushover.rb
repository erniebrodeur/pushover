require "net/https"
require "yajl"

require "pushover/version"
require "pushover/app"
require "pushover/user"
require "pushover/config"
require "pushover/optparser"

# The primary pushover namespace.
module Pushover

	def params
		Pushover.parameters
	end

	extend self

	attr_accessor :token, :user

	# push a message to across pushover, must supply all variables.
	def notification(message, title = nil, tokens={})
		url = URI.parse("https://api.pushover.net/1/messages")
		req = Net::HTTP::Post.new(url.path)
		req.set_form_data((params.merge(tokens.merge({:message => message, :title => title}))))
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

  # Returns true or false if all parameters are set.
  def parameters?
    parameters.values.all?
  end

  def keys
    keys ||= [:token, :user]
  end

  private

  # Helper to clean up recursive method in #parameters
  def get_var(var)
    self.instance_variable_get(var)
  end

end
