require 'spec_helper'

describe Pushover do
  describe Pushover::Response do
    let(:excon_response) { Excon::Response.new body: '{}', headers: {} }

    it { is_expected.to have_attributes(status: a_kind_of(String).or(be_nil)) }
    it { is_expected.to have_attributes(request: a_kind_of(String).or(be_nil)) }
    it { is_expected.to have_attributes(errors: a_kind_of(Array).or(be_nil)) }
    it { is_expected.to have_attributes(receipt: a_kind_of(String).or(be_nil)) }
    it { is_expected.to have_attributes(headers: a_kind_of(Hash).or(be_nil)) }
    it { is_expected.to have_attributes(attributes: a_kind_of(Hash).or(be_nil)) }

    it { expect(described_class).to respond_to(:create_from_excon_response).with(1).argument }

    describe "#to_s" do
      it "is expected to be purty." do
        expect(Pushover::Response.create_from_excon_response(excon_response).to_s).to include('status')
      end
    end

    describe "::create_from_excon_response" do
      it { expect(Pushover::Response.create_from_excon_response(excon_response)).to be_a_kind_of described_class }
    end
  end
end
