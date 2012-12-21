require 'spec_helper'

describe "Pushover" do
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
      keys.each {|k| Pushover.send("#{k}=", 'ladeda')}
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
      resp = Pushover.notification message:'a message', token:'good_token', user:'good_user'
      resp.code.should eq "200"
    end
  end

  describe "extra behavior" do
    describe "Priority" do
      it "can be set by number" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', priority:-1
        WebMock.should have_requested(:post, /.*api.pushover.net.*/).with do |req|
          req.body hash_including(priority:-1)
        end
      end
      it "can be set by text" do
        setup_webmocks
        Pushover.notification message:'a message', token:'good_token', user:'good_user', priority:'high'
        WebMock.should have_requested(:post, /.*api.pushover.net.*/).with do |req|
          req.body hash_including(priority:1)
        end
      end
    end

    describe "Time" do
      it "can be set by epoch"
      it "can be set by a text string"
      it "can be set rails style (-1.day, -12.months)"
    end
  end
end
