require 'optparse'

module Pushover
  # override the built-in [OptionParser], adding some nifty features.
  # Options[] is a hash value designed to collect the contents added to @options.

  class OptionParser < ::OptionParser
    def initialize
      super
      @options = {}

      on("-V", "--version", "Print version") { |version| @options[:version] = true}
      on("-u", "--user USER", "Which user, can be a saved name or token.") { |o| @options[:user] = o}
      on("-a", "--app APPKEY", "Which app to notify, can be a saved name or apikey.") { |o| @options[:appkey] = o}
      on("-T", "--title [TITLE]", "Set the title of the notification (optional).") { |o| @options[:title] = o}
      on("-c", "--config_file [FILE]", "Set the target config file.") {|o| @options[:config_file] = o}
      on("--save-app NAME", "Saves the application to the config file under NAME.") { |o| @options[:save_app] = [@options[:appkey], o]}
      on("--save-user NAME", "Saves the user to the config file under NAME.") { |o| @options[:save_user] = [@options[:user], o]}
    end

    # This will build an on/off option with a default value set to false.
    def bool_on(word, description = "")
      Options[word.to_sym] = false
      on "-#{word.chars.first}", "--[no]#{word}", description  do |o|
        Options[word.to_sym] == o
      end
    end

    # Build out the banner and calls the built in parse!
    # Loads any saved options automatically.
    def parse!
      @banner = "Send notifcations over to pushover.net.\n\n"
      super

      if @options[:version]
        puts Pushover::VERSION
        exit 0
      end

      # we need to mash in our config array.  To do this we want to make config
      # options that don't overwrite cli options.
      Config.each do |k,v|
        @options[k] = v if !@options[k] && ["applications", "users"].include?(k)
      end
    end

    # Entry point to the options hash
    # @return will return the value of key if provided, else the entire [Hash]
    def [](k = nil)
      return @options[k] if k
      return @options if @options.any?
      nil
    end

    # Set a value in the option array, used as a way to store the results of the parsed value.
    def []=(k,v)
      @options[k] = v
    end

    # Check to see if the option hash has any k/v paris.
    # @return [Boolean] true if any pairs at all, false otherwise.
    def empty?
      @options.empty?
    end
  end

  # Add a built in Options to the Pushover namespace, purely a convience thing.
  Options = OptionParser.new
end
