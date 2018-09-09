require 'spec_helper'

module Pushover
  describe Request do

    let(:endpoint) { :messages }
    let(:excon_connection) { Excon.new Api.url }
    let(:params) { { user: '1234', token: '1234', message: 'abcd' } }
    let(:request) { described_class.create }
    let(:excon_response) { Excon::Response.new(body: Oj.dump(body), status: 200, headers: headers) }
    let(:body) { { "status" => 1, "request" => "647d2300-702c-4b38-8b2f-d56326ae460b" } }
    let(:request) { Request.new }
    let(:response) { Response.create original: excon_response }
    let(:headers) do
      {
        "X-Limit-App-Limit":     7500,
        "X-Limit-App-Remaining": 7496,
        "X-Limit-App-Reset":     1_393_653_600
      }
    end

    it { expect(described_class).to be_a_kind_of(Class) }
    it { is_expected.to be_a_kind_of Creatable }

    describe "Instance Signatures" do
      it { is_expected.to respond_to(:push).with(2).argument }
    end

    describe "::push" do
      before do
        allow(Api).to receive(:connection).and_return excon_connection
        allow(excon_connection).to receive(:post).and_return excon_response
        allow(Response).to receive(:create).and_return response
        allow(response).to receive(:process).and_call_original
      end


      let(:request) { described_class.new }

      it 'is expected to call Api.connection.get with query set to the second argument' do
        request.push endpoint, params
        expect(excon_connection).to have_received(:post).with(query: a_kind_of(Hash), path: '1/messages.json')
      end

      it "is expected to call Response.create with the response set to original" do
        request.push endpoint, params
        expect(Response).to have_received(:create).with(original: a_kind_of(Excon::Response))
      end

      it "is expected to call response.process to populate the object" do
        request.push endpoint, params
        expect(response).to have_received(:process)
      end

      it "is expected to return request" do
        expect(request.push endpoint, params).to eq response
      end
    end
  end
end
