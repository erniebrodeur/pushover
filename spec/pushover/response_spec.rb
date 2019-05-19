require 'spec_helper'

describe Pushover do
  let(:params) { { 'token' => 't', 'key' => 'k', 'message' => 'message' } }

  describe Pushover::Response do
    it { expect(described_class).to respond_to(:create_from_excon_response).with(1).argument }

    describe "::create_from_excon_response" do
      let(:excon_response) { Excon::Response.new body: '{}', headers: {} }
      let(:subject) { Pushover::Response.create_from_excon_response excon_response }

      it { is_expected.to be_a_kind_of described_class }

      it "is expected to take an excon response and shit out self"
    end
  end
end
