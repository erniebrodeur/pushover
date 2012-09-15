module Pushover
	# The user module, saves any user information provided.
	module User
		# The User class, for a single instance of it.
		class User
			attr_accessor :name
			attr_accessor :token

			def initialize(token, name)
				@name = name
				@token = token
				Pushover::Config[:users] = {} if !Pushover::Config[:users]
				Pushover::Config[:users][name] = token
			end

		end

		# Find the apikey in the applications, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def self.find(word)
			return Config[:users][word] if Config[:users] && Config[:users].include?(word)
			word
		end

		# Add an application to the config file and save it.
		# @param [String] token is the token to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def self.add(token, name)
			User.new token, name
			Pushover::Config.save!
		end
	end
end
