# Since this testing requires an actual account, and a working internet, we don't
# run it as part of the standard suite.
# If you want to run these tests, add ENV["TEST_CLI"]
# If you have a credentials file already, you might find it beeps you.

# this should be a working cred file that can send messages for proper end to end testing.
CRED_FILE = "#{Dir.home}/.config/pushover/credentials.yaml"
FAKE_CRED_FILE = 'tmp/fake_credentials.yaml'
CMD = 'bundle exec bin/pushover'

require 'spec_helper.rb'
require 'cli_spec_helper.rb'

if ENV["TEST_CLI"] =~ /^t/
  describe "CLI Interface" do
    describe 'help' do
      it 'has options' do
        p = CLIProcess.new "#{CMD} --help"
        p.run!
        words = /user|app|title|priority|url|url_title|save-app|save-user|time|version/
        p.stdout.should =~ words
      end
    end

    describe "send" do
      it "sends messages" do
          p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} a message", 3, 3
          p.run!
          p.stdout.should include("success"), "#{p.stderr}"
      end

      it "sends messages (no credentials file)" do
          # for this trick, lets extract our creds from the cred file manually.
          # store them locally,then pass them back as app/user arguments.
          creds = YAML.load open(CRED_FILE).read

          app =  creds[:applications].first.values.first
          user = creds[:users].first.values.first
          p = CLIProcess.new "#{CMD} -a #{app} -u #{user} a message", 3, 3
          p.run!
          p.stdout.should include("success"), "#{p.stderr}"
      end

      it "lets me know when a message fails" do
        p = CLIProcess.new "#{CMD} --app fail --user now message goes here", 3, 3
        p.run!
        p.stdout.should include "ErrorCode"
      end
    end

    describe "saving" do
      it "saves app:key pairs" do
        p = CLIProcess.new "#{CMD} --config_file #{FAKE_CRED_FILE} --save-app default --app default"
        p.run!
        p.stdout.should include 'Saved'
        open(FAKE_CRED_FILE).read.should include 'default'
      end
      it "saves user:token pairs" do
        p = CLIProcess.new "#{CMD} --config_file #{FAKE_CRED_FILE} --save-user default --user default"
        p.run!
        p.stdout.should include 'Saved'
        open(FAKE_CRED_FILE).read.should include 'default'
      end
    end
    describe "sounds" do
      it "will list sounds" do
        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} --sound_list", 3, 3
        p.run!
        p.stdout.should include "Current Sound"
        p.stdout.should include "Pushover (default)"
        p.stdout.should include "None (silent)"
      end
      it "will play a sound (based on partial string)" do
        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} a message --sound none", 3, 3
        p.run!
        p.stdout.should include "success"
      end
      it "will fail if the sound is unavailble" do
        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} a message --sound slkdjg", 3, 3
        p.run!
        p.stdout.should include "No such sound"
      end
    end
    describe "emergency notifications" do
      it "will respond to emergency parameters" do
        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} an emergency message retry test --priority em --emergency_retry 180", 3, 3
        p.run!
        p.stdout.should include "success"

        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} an emergency message expires test --priority em --emergency_expire 7200", 3, 3
        p.run!
        p.stdout.should include "success"
      end

      it "will print the receipt" do
        p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} an emergency message --priority em", 3, 3
        p.run!
        p.stdout.should include "receipt"
      end

      it "will accept a callback url"
    end
  end
end


