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

			def initialize(name, token)
				@name = name
				@token = token
				Bini.config[:users] = {} if !Bini.config[:users]
				Bini.config[:users][name] = token
			end

		end

		extend self

		# Find the token in the users, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def find(word)
			return Bini.config[:users][word] if Bini.config[:users] && Bini.config[:users][word]
			word
		end

		# Add an application to the config file and save it.
		# @param [String] token is the token to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def add(name, token)
			User.new name, token
			Bini.config.save!
		end

		def remove(name)
			Bini.config[:users].delete name if Bini.config[:users]
		end

		# Return the current user selected, or the first one saved.
		def current_user
			# did something get supplied on the cli? try to find it.
			if Bini::Options[:token]
				@current_user = find Bini::Options[:token]
			end

			# no?  do we have anything we can return?
			if !@current_user
				@current_user = find Bini.config[:users].first[0] if Bini.config[:users]
			end
			@current_user
		end

		# Set the current_user to whatever you want it to be.
		def current_user=(user)
			@current_user = user
		end

		# Will return true if it can find a user either via the cli or save file.
		def current_user?
			return true if @current_user
			return nil
		end
	end
end
