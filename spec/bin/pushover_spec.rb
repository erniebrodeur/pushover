require 'spec_helper'
require 'pushover/version'
require 'open3'

# we use a global here as the output buffer so we don't have to rerun the command every time just to test a string.
describe 'pushover' do
  describe 'help' do
    subject { $output }

    before(:all) { $output, $status = Open3.capture2e "bundle exec pushover help" }

    it { is_expected.to include 'pushover' }
    it { is_expected.to include 'message' }
    it { is_expected.to include '--help' }
    it { is_expected.to include '--version' }

    describe "global options" do
      it { is_expected.to include 'GLOBAL OPTIONS' }
      it { is_expected.to include('-a').and(include('--app-token')) }
      it { is_expected.to include('-k').and(include('--key')) }
    end

    describe "commands" do
      it { is_expected.to include 'COMMANDS' }
      it { is_expected.to include 'help' }
      it { is_expected.to include 'pushover' }
    end

    it { expect($status.to_i).to be 0 }
  end

  describe '--version' do
    subject { $output }

    before(:all) { $output = `bundle exec pushover help` }

    it { is_expected.to include Pushover::VERSION }
    it { expect($status.to_i).to be 0 }
  end

  describe 'message help' do
    subject { $output }

    before(:all) { $output, $status = Open3.capture2e "bundle exec pushover help message" }

    it { is_expected.to include 'send a message' }
    it { expect($status.to_i).to be 0 }

    %i[title attachment device url url-title priority sound timestamp].each do |flag|
      it { is_expected.to include "--#{flag}" }
    end
  end

  describe 'message' do
    subject { $output }

    before(:all) { $output, $status = Open3.capture2e "bundle exec pushover -aa -kk message 'test message'" }

    it { expect($status.to_i).to be 0 }
  end
end
