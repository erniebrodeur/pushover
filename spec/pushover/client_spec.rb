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
end
