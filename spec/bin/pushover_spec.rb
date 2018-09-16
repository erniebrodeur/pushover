require 'spec_helper'
require 'pushover/version'

describe 'pushover' do
  command 'pushover'
  its(:exitstatus) { is_expected.to eq 0 }

  describe '--version' do
    command 'pushover --version'
    its(:stdout) { is_expected.to include Pushover::VERSION }
    its(:exitstatus) { is_expected.to eq 0 }
  end

  describe 'help' do
    command 'pushover help'
    its(:stdout) { is_expected.to include 'pushover' }
    its(:stdout) { is_expected.to include '--help' }
    its(:stdout) { is_expected.to include '--version' }
    its(:exitstatus) { is_expected.to eq 0 }

    describe "global options" do
      its(:stdout) { is_expected.to include 'GLOBAL OPTIONS' }
      its(:stdout) { is_expected.to include('-a').and(include('--app-token')) }
      its(:stdout) { is_expected.to include('-t').and(include('--token')) }
    end

    describe "commands" do
      its(:stdout) { is_expected.to include 'COMMANDS' }
      its(:stdout) { is_expected.to include 'help' }
    end
  end
end
