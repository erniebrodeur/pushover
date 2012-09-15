module Pushover
	attr_accessor :name
	attr_accessor :api_key

	class App
		def initialize(api_key, name)
			@name = name
			@api_key = api_key
			Pushover::Config['applications'] = {} if !Pushover::Config['applications']
			if name
				Pushover::Config['applications'][name] = api_key
			else
				Pushover::Config['applications'][api_key] = api_key
			end
		end
	end

	def self.add_app(api_key, name)
		App.new api_key, name
		Pushover::Config.save!
	end
end
