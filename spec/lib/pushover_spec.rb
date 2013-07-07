require 'spec_helper'

describe "Pushover" do
  before :all do
    Bini.cache_dir = "tmp/cache_dir"
    Bini.data_dir = "tmp/data_dir"
    Bini.config_dir = "tmp/config_dir"
  end
  before :each do
    App.current_app = nil
    User.current_user = nil
    Pushover.clear
  end

  describe "#clear" do
    it "will erase all the attributes in Pushover" do
      Pushover.send("#{keys.first}=", "something")
      Pushover.clear
      parameters.each {|k,v| v.should be_nil}
    end
  end

  describe "#parameters?" do
    it 'will return true only if every key is set to something.' do
      keys.each do |k|
        if k == :timestamp
          Pushover.send("timestamp=", '1970-01-01 00:00:01 UTC')
        else
          Pushover.send("#{k}=", 'ladeda')
        end
      end
      parameters?.should eq true
    end
    it 'will return false otherwise.' do
      Pushover.send("#{keys.first}=", "something")
      parameters?.should eq false
    end
  end

  describe "#configure" do
    Pushover.keys.each do |key|
      it "#{key} can be configured via .configure" do
        r = "acdfef"
        Pushover.configure do |c|
          c.instance_variable_set "@#{key}", r
        end
        Pushover.send(key).should eq r
      end
    end
  end

  describe "#notification" do
    it "can send a notification" do
      setup_webmocks
      Pushover.notification message:'a message', token:'good_token', user:'good_user'
      WebMock.should have_requested(:post, /.*api.pushover.net.*/).with do |req|
        puts req.body hash_including(priority:'ajkasdfj')
      end
    end
  end

  describe "extra behavior" do
    describe "Priority" do
      it "can be set by text" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', priority:'low'
        WebMock.should have_requested(:post, /.*api.pushover.net.*/).with { |req| req.body.include? 'priority=-1'}
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', priority:'high'
        WebMock.should have_requested(:post, /.*api.pushover.net.*/).with { |req| req.body.include? 'priority=1'}
      end
      it "falls back to normal" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', priority:'kwkru'
        WebMock.should have_requested(:post, /api.pushover.net/).with { |req| req.body.include? 'priority=0' }
      end
    end

    describe "Time" do
      it "can be set by epoch" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', timestamp:1000
        Pushover.notification message:'a message', token:'good_token', user:'good_user', timestamp:'1000'
        WebMock.should have_requested(:post, /api.pushover.net/).with { |req| req.body.include? 'timestamp=1000' }.twice
      end

      it "can be set by a text string" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', timestamp:'1970-01-01 00:00:01 UTC'
        WebMock.should have_requested(:post, /api.pushover.net/).with { |req| req.body.include? 'timestamp=1' }
      end
    end

    describe "Sounds" do
      it "will cache the sounds locally for at least a day" do
        setup_webmocks
        cache_file = "#{Bini.cache_dir}/sounds.json"
        FileUtils.rm(cache_file) if File.exist?(cache_file)
        Pushover.sounds.keys.should include("pushover")
        stat = File.stat(cache_file)
        Pushover.sounds.keys.should include("none")
        stat.mtime.to_i.should eq File.stat(cache_file).mtime.to_i
      end
    end

  end
end


