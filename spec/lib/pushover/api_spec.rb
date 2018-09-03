require 'spec_helper'

module Pushover
  describe Api do
    it { expect(described_class).to respond_to(:endpoints).with(0).argument }
    it { expect(described_class).to respond_to(:connection).with(0).argument }
    it { expect(described_class).to respond_to(:url).with(0).argument }
    it { expect(described_class).to respond_to(:sounds).with(0).argument }
    it { expect(described_class).to respond_to(:initialize).with(0).argument }

    describe '::initialize' do
      before { described_class.initialize }

      it "is expected to set excon default Headers Content-Type to 'application/json'" do
        expect(Excon.defaults[:headers]).to include('Content-Type' => 'application/json')
      end

      it "is expected to set excon default Headers User-Agent to 'pushover (ruby gem) v#{Pushover::VERSION}'" do
        expect(Excon.defaults[:headers]).to include('User-Agent' => "pushover (ruby gem) v#{Pushover::VERSION}")
      end
    end

    describe '::endpoints' do
      it { expect(described_class.endpoints).to be_a_kind_of(Array) & include(a_kind_of(Symbol)) }
    end

    describe '::connection' do
      it "is expected to return an excon connection" do
        expect(described_class.connection).to be_a_kind_of Excon::Connection
      end
    end

    describe '::sounds' do
      it { expect(described_class.sounds).to be_a_kind_of(Array) & include(a_kind_of(Symbol)) }
    end

    describe '::url' do
      it { expect(described_class.url).to eq 'https://api.pushover.net' }
    end
  end
end
