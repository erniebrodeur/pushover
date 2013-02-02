# Since this testing requires an actual account, and a working internet, we don't
# run it as part of the standard suite.
# If you want to run these tests, add ENV["TEST_CLI"]
# If you have a credentials file already, you might find it beeps you.

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
      if !File.exist? CRED_FILE
        it "sends messages (no credentials file)"
      else
        it "sends messages" do
          p = CLIProcess.new "#{CMD} --config_file #{CRED_FILE} a message", 3, 3
          p.run!
          #binding.pry
          p.stdout.should include("success"), "#{p.stderr}"
        end
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
  end
end
