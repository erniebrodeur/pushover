module Pushover
	# The user module, saves any user information provided.
	module User
		# The User class, for a single instance of it.
		# @!attribute name
		# 	@return [String] the name of the user.
		# @!attribute token
		#   @return [String] the token of the user.
		class User
			attr_accessor :name
			attr_accessor :token

			def initialize(token, name)
				@name = name
				@token = token
				Config[:users] = {} if !Config[:users]
				Config[:users][name] = token
			end

		end

		extend self

		# Find the apikey in the applications, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def find(word)
			return Config[:users][word] if Config[:users][word]
			word
		end

		# Add an application to the config file and save it.
		# @param [String] token is the token to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def add(token, name)
			User.new token, name
			Pushover::Config.save!
		end

		# Return the current user selected, or the first one saved.
		def current_user
			return @current_user if @current_user

			# did something get supplied on the cli? try to find it.
			if Options[:user]
				@current_user = Pushover::User.find Options[:user]
			end

			# no?  do we have anything we can return?
			if !@current_user
				@current_user = Config[:users].first
			end
			@current_user
		end

		# Will return true if it can find a user either via the cli or save file.
		def current_user?
			return true if current_user
			return nil
		end
	end
end
