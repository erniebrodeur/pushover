require 'spec_helper'

describe "Pushover" do
  before :each do
    setup_webmocks
  end
	it "can send a notification" do
    resp = Pushover.notification message:'a message', token:'good_token', user:'good_user'
    resp.code.should eq "200"
  end
end
