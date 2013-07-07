module Pushover
	# Stores a application definition in the config file.
	module App
		# an instance of an application.
		# @!attribute name
		# 	@return [String] the name of the application.
		# @!attribute api_key
		#   @return [String] the api_key of the application.
		class App
			attr_accessor :name
			attr_accessor :api_key

			def initialize(name, api_key)
				@name = name
				@api_key = api_key
				Bini::Config[:applications] = {} if !Bini::Config[:applications]
				Bini::Config[:applications][name] = api_key
			end
		end

		extend self

		# Find the apikey in the applications, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def find(word)
			return Bini::Config[:applications][word] if Bini::Config[:applications] && Bini::Config[:applications][word]
			word
		end

		# Add an application to the config file and save it.
		# @param [String] api_key is the api_key to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def add(name, api_key)
			App.new name, api_key
			Bini::Config.save!
		end

		def remove(name)
			Bini::Config[:applications].delete name if Bini::Config[:applications]
		end
		# Return the current app selected, or the first one saved.
		def current_app
			# did something get supplied on the cli? try to find it.
			if Bini::Options[:apikey]
				@current_app = find Bini::Options[:apikey]
			else
				@current_app = find Bini::Config[:applications].values.first if Bini::Config[:applications]
			end
			@current_app
		end

		def current_app=(app)
			@current_app = app
		end

		# Will return true if we can find an application either via the cli or save file.
		def current_app?
			return true if current_app
			return nil
		end
	end
end
