require 'spec_helper'

describe "user" do
	before(:each) do
		Bini.config.file = "tmp/test.save"
		Bini.config.clear
	end

	it "can add a user to the Config[:application] hash." do
		User.add "foo", "bar"
		Bini.config[:users]["foo"].should eq("bar")
	end

	it "can remove a user from the hash." do
		User.add "foo", "bar"
    User.remove "foo"
    Bini.config[:users]["foo"].should be_nil
  end

	it "can find the token from the name" do
		User.add "foo", "bar"
		User.find("foo").should eq("bar")
	end
end


