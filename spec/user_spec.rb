require 'pushover'

describe "user" do
	before(:each) do
		Pushover::Config.save_file = "test.save"
		Pushover::Config.clear
	end

	it "can add a user to the Config[:application] hash." do
		Pushover::User.add "bar", "foo"
		Pushover::Config[:users]["foo"].should eq("bar")
	end

	it "can remove a user from the hash."
	it "can find the token from the name" do
		Pushover::User.add "bar", "foo"
		Pushover::User.find("foo").should eq("bar")
	end
end


