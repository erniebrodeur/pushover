#require "pushover/version"
require "net/https"

module Pushover
	# push a message to across pushover, must supply all variables.
	def self.notification(token, application, message, title = nil)
		url = URI.parse("https://api.pushover.net/1/messages")
		req = Net::HTTP::Post.new(url.path)
		req.set_form_data({:token => token, :user => application, :message => message, :title => title})
		res = Net::HTTP.new(url.host, url.port)
		res.use_ssl = true
		res.verify_mode = OpenSSL::SSL::VERIFY_PEER
		res.start {|http| http.request(req) }
	end
end
