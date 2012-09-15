module Pushover

	module App
		class App
			attr_accessor :name
			attr_accessor :api_key

			def initialize(api_key, name)
				@name = name
				@api_key = api_key
				Pushover::Config[:applications] = {} if !Pushover::Config[:applications]
				if name
					Pushover::Config[:applications][name] = api_key
				else
					Pushover::Config[:applications][api_key] = api_key
				end
			end

		end

		# Find the apikey in the applications, or pass on the word to try direct access.
		# @param [String] word the search token, can be an apikey or appname.
		# @return [String] return the apikey (if it can find one) or the word itself.
		def self.find(word)
			return Config[:applications][word] if Config[:applications].include? word
			word
		end

		# Add an application to the config file and save it.
		# @param [String] api_key is the api_key to be used.
		# @param [String] name is the short name that can be referenced later.
		# @return [Boolean] return the results of the save attempt.
		def self.add(api_key, name)
			App.new api_key, name
			Pushover::Config.save!
		end
	end

end
