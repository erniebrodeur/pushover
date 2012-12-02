require 'spec_helper'

describe "user" do
	before(:each) do
		Bini.config.file = "tmp/test.save"
		Bini.config.clear
		User.current_user = nil
	end

	it "can add a user to the Config[:users] hash." do
		User.add "foo", "bar"
		Bini.config[:users]["foo"].should eq("bar")
	end

	it "can remove a user from the hash." do
		User.add "foo", "bar"
		User.remove "foo"
		Bini.config[:users]["foo"].should be_nil
	end

	describe "#find" do
		it "can find the token from the name" do
			User.add "foo", "bar"
			User.find("foo").should eq("bar")
		end
		it "If it can't find the token, it will still try whatever was passed" do
			User.find("tryme").should eq "tryme"
		end
	end

	describe "#current_user" do
		it "will look on the cli first" do
			Bini::Options[:token] = 'atoken'
			User.current_user.should eq "atoken"
		end
		it "will grab the first user in the config as a last resort" do
			User.add "foo", "bar2"
			Bini.config.save
			Bini::Options[:token] = nil
			User.current_user.should eq "bar2"
		end
	end

	describe "#current_user?" do
		it "Will return true if we have a current_user" do
			Bini::Options[:token] = 'somethingsilly'
			User.current_user.should eq 'somethingsilly'
		end
		it "Will return nil otherwise" do
			User.current_user?.should be_nil
		end
	end
end
