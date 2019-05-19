require 'spec_helper'

describe Pushover do
  let(:params) { { 'token' => 't', 'key' => 'k', 'message' => 'message' } }

  describe Pushover::Message do
    it { is_expected.to respond_to(:push).with(0).argument }

    describe "#push" do
      let(:subject) { Pushover::Message.new(params).push }

      it { is_expected }

      ['token', 'key', 'message'].each do |param|
        context "when #{param} is not supplied" do
          before { params.delete param }

          it { expect { subject }.to raise_error RuntimeError, /#{param} must be supplied/ }
        end
      end
    end
  end

  describe Pushover::Response do
    it { expect(described_class).to respond_to(:create_from_excon_response).with(1).argument }

    describe "::create_from_excon_response" do
      let(:excon_response) { Excon::Response.new body: '{}', headers: {} }
      let(:subject) { Pushover::Response.create_from_excon_response excon_response }

      it { is_expected.to be_a_kind_of described_class }

      it "is expected to take an excon response and shit out self"
    end
  end
  #   let(:subject) { described_class params }

  #   before { allow(described_class).to receive(:connection).and_return(body: '') }

  #   it { expect { subject }.not_to raise_error }

  #   it "is expected to accept a hash" do
  #     expect { described_class.message({}) }.not_to raise_error
  #   end

  #   it "is expected to POST a message to Pushover"

  #   include_examples "return results"

  #   context "when status is not okay" do
  #     it "is expected to raise error"
  #   end
  # end

  # describe "#receipt" do
  #   let(:subject) { described_class.receipt params }

  #   it "is expected to GET the receipt endpoint"
  #   it "is expected to accept a hash"
  # end
end
