require 'pushover'

describe "application" do
	before(:each) do
		Bini.config.file = "test.save"
		Bini.config.clear
	end

	it "can add a application to the Config[:application] hash." do
		Pushover::App.add "bar", "foo"
		Bini.config[:applications]["foo"].should eq("bar")
	end

	it "can remove a application from the hash."
	it "can find the apikey from the name" do
		Pushover::App.add "bar", "foo"
		Pushover::App.find("foo").should eq("bar")
	end
end
