require 'pushover'

describe "Config" do
	before(:all) do
		Pushover::Config.save_file = "config_spec.tmp"
		Pushover::Config.clear
	 	Pushover::Config[:test] = true
	 	Pushover::Config.save!
	end

	it "should exist" do
		expect { Pushover::Config }.to_not be(nil)
	end

	it "should have a save_file" do
		Pushover::Config.save_file.should eq("config_spec.tmp")
	end

	it "save_dir should be the basename of save_file" do
		Pushover::Config.save_dir.should eq(File.dirname Pushover::Config.save_file)
	end

	it "should save if not empty" do
	 	File.exists?(Pushover::Config.save_file).should be(true)
	end

	it "should load" do
		Pushover::Config.load
		Pushover::Config[:test].should eq(true)
	end
end
