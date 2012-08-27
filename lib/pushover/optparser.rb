require 'optparse'

module Pushover
  class OptionParser < ::OptionParser
    def initialize
      super
      @options = {}

      on("-V", "--version", "Print version") { |version| @options[:version] = true}
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

    def [](k)
      @options[k]
    end

    def []=(k,v)
      @options[k] = v
    end
  end

  Options = OptionParser.new
end
