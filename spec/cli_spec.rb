describe "CLI Interface" do
	# the save file to be used.
	Save_file = 'spec/test_config'
	# the exact string to execute the test version of pushover.
	Exec = "bundle exec bin/pushover"
	describe "config file" do
		it "Can select the config file (short form)" do
			output = `#{Exec} -c #{Save_file}`
			output.include? Save_file
		end
		it "Can select the config file (long form)" do
		end
	end
	it "Can save an app."
	it "Can save a user."
	describe "Sending a message" do
		it "With no saved info."
		context "With saved information" do
			it "With a saved user"
			it "With a saved app"
			it "With both"
		end
		describe "Title" do
			it "can send with a title"
			it "can send without a title"
		end
	end
	it "provides the proper version number"
end

