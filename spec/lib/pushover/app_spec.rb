require 'pushover'

include Pushover

describe "application" do
	before(:each) do
		Bini.config.file = "tmp/test.save"
		Bini.config.clear
	end

	it "can add a application to the Config[:application] hash." do
		App.add "foo", "bar"
		Bini.config[:applications]["foo"].should eq("bar")
	end

	it "can remove a application from the hash." do
		App.add "foo", "bar"
    App.remove "foo"
    Bini.config[:applications]["foo"].should be_nil
  end

	it "can find the apikey from the name" do
		App.add "foo", "bar"
		App.find("foo").should eq("bar")
	end
end
