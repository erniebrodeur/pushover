module Pushover
  module Priority
    extend self
    attr_reader   :priority



    def priority=(level)
      @priority = parse level
    end

    def parse(level)
      return level if level.class == Fixnum
      if level.class == String
        LEVELS.each do |k,v|
          return v if k.to_s.start_with? level.downcase
        end
      end

      return 0
    end

    # Pull one from cache, or fetch one if not available.
    def process_receipt(receipt)
      # find the receipt based on the prefix
      # if it's not their get a new one
      # if it's not expired and not ack'ed, get a new one
      # if we have a new one (or update), store
    end

    # get the status of a receipt
    def receipt_status(prefix)
      process_receipt
      # store
      # return
    end

    # returns a string suitable for CLI output.
    def pretty_print_receipt
    end

    def is_emergency?(priority)
      return true if priority && Pushover::Priority.parse(priority) == LEVELS[:emergency]
      return false
    end

    # A sash for our receipts.
    Receipts = Bini::Sash.new options:{
      file:"#{Bini.cache_dir}/receipts.json", auto_load:true
    }
    LEVELS = {
      low:-1,
      normal:0,
      high:1,
      emergency:2
    }
  end
end








