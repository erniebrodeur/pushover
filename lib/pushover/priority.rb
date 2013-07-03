module Pushover
  module Priority
    extend self

    # A sash for our receipts.
    Receipts = Bini::Sash.new options:{
      file:"#{Bini.cache_dir}/receipts.yaml", auto_load:true, auto_save:true
    }
    LEVELS = {
      low:-1,
      normal:0,
      high:1,
      emergency:2
    }

    def priority=(level)
      @priority = parse level
    end

    def parse(level)
      return level if level.class == Fixnum
      if level.class == String
        LEVELS.each { |k,v| return v if k.to_s.start_with? level.downcase }
      end

      return 0
    end

    # Pull one from cache, or fetch one if not available.
    def find_receipt(prefix)
      results = Receipts.select { |k,v| k =~ /^#{prefix}/ }
      return nil if results.empty?
      return results.first
    end

    def process_receipt(receipt)
      r = find_receipt receipt
      # complicated if warning.  If r isn't made, or if it is made and not expired or acked.
      r = fetch_receipt(receipt) if !r

      return nil if !r

      Receipts[receipt] = r.to_h

      return Receipts[receipt]
    end

    # returns a string suitable for CLI output.
    def pretty_print_receipt(receipt)

    end

    def is_emergency?(priority)
      return true if priority && Pushover::Priority.parse(priority) == LEVELS[:emergency]
      return false
    end

    private
    def fetch_receipt(receipt)
      HTTParty.get "https://api.pushover.net/1/receipts/#{receipt}.json",
        body:{token:Pushover::App.current_app}
    end
  end
end








