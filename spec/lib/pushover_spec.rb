require 'spec_helper'

describe Pushover do
  it { is_expected.to have_attributes(connection: a_kind_of(Excon::Connection).or(be_nil)) }

  describe '#connection' do
    let(:subject) { described_class.connection }

    it { is_expected.to be_a_kind_of Excon::Connection }

    describe ".connection_uri" do
      it { expect(described_class.connection.connection_uri).to eq 'https://api.pushover.net:443' }
    end
  end
end
