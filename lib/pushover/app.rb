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

			def initialize(api_key, name)
				@name = name
				@api_key = api_key
				Config[:applications] = {} if !Config[:applications]
				if name
					Config[:applications][name] = api_key
				else
					Config[:applications][api_key] = api_key
				end
			end
		end

		extend self

		# Find the apikey in the applications, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def find(word)
			return Config[:applications][word] if Config[:applications][word]
			word
		end

		# Add an application to the config file and save it.
		# @param [String] api_key is the api_key to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def add(api_key, name)
			App.new api_key, name
			Pushover::Config.save!
		end

		# Return the current app selected, or the first one saved.
		def current_app
			return @current_app if @current_app

			# did something get supplied on the cli? try to find it.
			if Options[:appkey]
				@current_app = Pushover::App.find Options[:appkey]
			end

			# no?  do we have anything we can return?
			if !@current_app
				@current_app = Config[:applications].first
			end
		end

		def current_app?
			return true if @current_app == true
			return nil
		end
	end
end
