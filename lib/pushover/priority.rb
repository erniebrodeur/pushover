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

    def update_receipts
      updates = Receipts.select {|k,v| v["acknowledged"] == 0}
      updates.keys.each do |key|
        process_receipt key
      end
    end

    def process_receipt(receipt)
      r = fetch_receipt(receipt)

      return nil if !r
      Receipts.store receipt, r.to_h
      return Receipts[receipt]
    end

    def is_emergency?(priority)
      return true if priority && Pushover::Priority.parse(priority) == LEVELS[:emergency]
      return false
    end

    private
    def fetch_receipt(receipt)
      HTTParty.get("https://api.pushover.net/1/receipts/#{receipt}.json",
        body:{token:Pushover::App.current_app})
    end
  end
end
