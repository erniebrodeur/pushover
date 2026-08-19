require 'spec_helper'

describe Pushover::Client do
  describe '#initialize' do
    it 'requires an application token' do
      expect { described_class.new(token: '') }.to raise_error ArgumentError, /token must be supplied/
    end
  end

  describe '#messages' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a message resource' do
      expect(client.messages).to be_a Pushover::Messages
    end

    it 'reuses the message resource' do
      messages = client.messages

      expect(client.messages).to equal messages
    end
  end

  describe '#receipts' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a receipt resource' do
      expect(client.receipts).to be_a Pushover::Receipts
    end

    it 'reuses the receipt resource' do
      receipts = client.receipts

      expect(client.receipts).to equal receipts
    end
  end

  describe '#users' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a user resource' do
      expect(client.users).to be_a Pushover::Users
    end

    it 'reuses the user resource' do
      users = client.users

      expect(client.users).to equal users
    end
  end

  describe '#sounds' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a sounds resource' do
      expect(client.sounds).to be_a Pushover::Sounds
    end

    it 'reuses the sounds resource' do
      sounds = client.sounds

      expect(client.sounds).to equal sounds
    end
  end

  describe '#limits' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a limits resource' do
      expect(client.limits).to be_a Pushover::Limits
    end

    it 'reuses the limits resource' do
      limits = client.limits

      expect(client.limits).to equal limits
    end
  end

  describe '#glances' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a glances resource' do
      expect(client.glances).to be_a Pushover::Glances
    end

    it 'reuses the glances resource' do
      glances = client.glances

      expect(client.glances).to equal glances
    end
  end

  describe '#groups' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a groups resource' do
      expect(client.groups).to be_a Pushover::Groups
    end

    it 'reuses the groups resource' do
      groups = client.groups

      expect(client.groups).to equal groups
    end
  end

  describe '#subscriptions' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a subscriptions resource' do
      expect(client.subscriptions).to be_a Pushover::Subscriptions
    end

    it 'reuses the subscriptions resource' do
      subscriptions = client.subscriptions

      expect(client.subscriptions).to equal subscriptions
    end
  end

  describe '#licenses' do
    subject(:client) { described_class.new(token: 'token') }

    it 'returns a licenses resource' do
      expect(client.licenses).to be_a Pushover::Licenses
    end

    it 'reuses the licenses resource' do
      licenses = client.licenses

      expect(client.licenses).to equal licenses
    end
  end

  describe '#teams' do
    subject(:client) { described_class.new(token: 'team-token') }

    it 'returns a teams resource' do
      expect(client.teams).to be_a Pushover::Teams
    end

    it 'reuses the teams resource' do
      teams = client.teams

      expect(client.teams).to equal teams
    end
  end
end
