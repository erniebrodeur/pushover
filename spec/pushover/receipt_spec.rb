require 'spec_helper'

describe Pushover::Receipt do
  it { is_expected.to have_attributes(receipt: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(token: a_kind_of(String).or(be_nil)) }

  it { is_expected.to respond_to(:get).with(0).argument }

  describe "#push" do
    let(:params) { { 'token' => 't', 'receipt' => 'receipt' } }

    it "is expected to send" do
      expect { described_class.new(params).get }.to raise_error Excon::Error::StubNotFound
    end

    ['token', 'receipt'].each do |param|
      context "when #{param} is not supplied" do
        before { params.delete param }

        it { expect { described_class.new(params).get }.to raise_error RuntimeError, /#{param} must be supplied/ }
      end
    end
  end
end
