require 'spec_helper'

describe Pushover::Response do
  let(:excon_response) { Excon::Response.new body: '{}', headers: {} }

  it { is_expected.to have_attributes(status: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(request: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(errors: a_kind_of(Array).or(a_kind_of(Hash)).or(be_nil)) }
  it { is_expected.to have_attributes(receipt: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(headers: a_kind_of(Hash).or(be_nil)) }
  it { is_expected.to have_attributes(attributes: a_kind_of(Hash).or(be_nil)) }

  it { expect(described_class).to respond_to(:create_from_excon_response).with(1).argument }

  describe "#to_s" do
    it "is expected to be purty." do
      expect(described_class.create_from_excon_response(excon_response).to_s).to include('status')
    end

    it 'formats structured errors' do
      excon_response.body = Oj.dump('status' => 0, 'errors' => { 'token' => ['has no license credits'] })

      expect(described_class.create_from_excon_response(excon_response).to_s)
        .to include('errors: {"token"=>["has no license credits"]}')
    end
  end

  describe "::create_from_excon_response" do
    it { expect(described_class.create_from_excon_response(excon_response)).to be_a described_class }
  end
end
