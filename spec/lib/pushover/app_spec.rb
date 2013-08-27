require 'spec_helper'

describe "application" do
	before(:each) do
		Bini::Config.clear
		Bini::Options.clear
		App.current_app = nil
	end

	it "can add a application to the Config[:application] hash." do
		App.add "foo", "bar"
		Bini::Config[:applications]["foo"].should eq("bar")
	end

	it "can remove a application from the hash." do
		App.add "foo", "bar"
		App.remove "foo"
		Bini::Config[:applications]["foo"].should be_nil
	end

	describe "#find" do
		it "can find the apikey from the name" do
			App.add "foo", "bar"
			App.find("foo").should eq("bar")
		end
		it "If it can't find the apikey, it will still try whatever was passed" do
			App.find("tryme").should eq "tryme"
		end
	end

	describe "#current_app" do
		it "will look on the cli first" do
			Bini::Options[:token] = 'anapikey'
			App.current_app.should eq "anapikey"
		end
		it "will grab the first app in the config as a last resort" do
			App.add "foo", "bar2"
			Bini::Config.save
			Bini::Options[:token] = nil
			App.current_app.should eq "bar2"
		end
	end

	describe "#current_app?" do
		it "Will return true if we have a current_app" do
			Bini::Options[:token] = 'somethingsilly'
			App.current_app.should eq 'somethingsilly'
		end
		it "Will return nil otherwise" do
			App.current_app?.should be_nil
		end
	end
end

