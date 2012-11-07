# describe "CLI Interface" do
# 	# the save file to be used.
# 	SaveFile = 'spec/test_config'
# 	# the exact string to execute the test version of pushover.
# 	Exec = "bundle exec bin/pushover"
# 	ExecConfig = Exec + " -c #{SaveFile}"
# 	describe "Can select the config file" do
# 		it "short form (-c)" do
# 			output = `#{ExecConfig}`
# 			output.include? "Selecting config file: #{SaveFile}"
# 		end

# 		it "long form (--config_file)" do
# 			output = `#{Exec} -c #{SaveFile}`
# 			output.include? "Selecting config file: #{SaveFile}"
# 		end
# 	end
# 	describe "Saving" do
# 		it "Application." do
# 			output = `#{ExecConfig} --app 'test_app_api_key' --save-app test_app`
# 			output.include?("Save successful").should be_true
# 		end
# 		it "User." do
# 			output = `#{ExecConfig} --user 'test_user_key' --save-app test_user`
# 			output.include?("Save successful").should be_true
# 		end
# 	end
# 	describe "Sending a message" do
# 		it "With no saved info."
# 		context "With saved information" do
# 			it "With a saved user"
# 			it "With a saved app"
# 			it "With both"
# 		end
# 		describe "Title" do
# 			it "can send with a title"
# 			it "can send without a title"
# 		end
# 	end
# 	it "provides the proper version number"
# end

