require 'optparse'

module Pushover
  class OptionParser < ::OptionParser
    def initialize
      super
      @options = {}

      on("-V", "--version", "Print version") { |version| @options[:version] = true}
      on("-t", "--token TOKEN", "Set your identity token.") { |o| @options[:token] = o}
      on("-a", "--app-key APPKEY", "Set the receiving application key.") { |o| @options[:appkey] = o}
      on("-m", "--message MESSAGE", "The message to be sent.") { |o| @options[:message] = o}
      on("-T", "--title [TITLE]", "Set the title of the notification (optional).") { |o| @options[:title] = o}
    end

    # This will build an on/off option with a default value set to false.
    def bool_on(word, description = "")
      Options[word.to_sym] = false
      on "-#{word.chars.first}", "--[no]#{word}", description  do |o|
        Options[word.to_sym] == o
      end
    end

    def parse!
      @banner = Pushover::VERSION
      super

      if @options[:version]
        puts Pushover::VERSION
        exit 0
      end

      # we need to mash in our config array.  To do this we want to make config
      # options that don't overwrite cli options.
      Config.each do |k,v|
        @options[k] = v if !@options[k]
      end
    end

    def [](k = nil)
      return @options[k] if k
      return @options if @options.any?
      nil
    end

    def []=(k,v)
      @options[k] = v
    end
  end

  Options = OptionParser.new
end
