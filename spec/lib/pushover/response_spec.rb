require 'spec_helper'

module Pushover
  describe Response do
    let(:body) { { "status": 1, "request": "647d2300-702c-4b38-8b2f-d56326ae460b" } }
    let(:receipt_body) { { "status": 1, "request": "647d2300-702c-4b38-8b2f-d56326ae460b", "receipt": 'abcdefg' } }
    let(:error_body) { { "user": "invalid", "errors": ["user identifier is invalid"], "status": 0, "request": "5042853c-402d-4a18-abcb-168734a801de" } }
    let(:headers) do
      {
        "X-Limit-App-Limit":     7500,
        "X-Limit-App-Remaining": 7496,
        "X-Limit-App-Reset":     1_393_653_600
      }
    end
    let(:excon_response) { Excon::Response.new(body: Oj.dump(body), status: 200, headers: headers) }
    let(:response) { described_class.create original: excon_response }

    it { is_expected.to be_a_kind_of Creatable }

    it { expect(described_class).to be_a_kind_of(Class) }

    describe "Attributes" do
      it { is_expected.to have_attributes(errors: []) }
      it { is_expected.to have_attributes(limit: nil) }
      it { is_expected.to have_attributes(original: nil) }
      it { is_expected.to have_attributes(receipt: nil) }
      it { is_expected.to have_attributes(remaining: nil) }
      it { is_expected.to have_attributes(request: nil) }
      it { is_expected.to have_attributes(reset: nil) }
      it { is_expected.to have_attributes(status: a_kind_of(Numeric)) }
    end

    describe "Instance Signatures" do
      it { is_expected.to respond_to(:process).with(0).argument }
      it { is_expected.to respond_to(:process_body).with(0).argument }
      it { is_expected.to respond_to(:process_headers).with(0).argument }
    end

    describe '::process' do
      shared_examples 'process_verb' do |verb|
        it "is expected to call process_#{verb}" do
          allow(response).to receive("process_#{verb}".to_sym)
          response.process
          expect(response).to have_received("process_#{verb}".to_sym)
        end
      end

      include_examples 'process_verb', 'body'
      include_examples 'process_verb', 'headers'
    end

    describe '::process_body' do
      context "when a receipt is provided" do
        let(:body) { receipt_body }

        it "is expected to set receipt" do
          expect { response.process_body }.to change(response, :receipt).to body[:receipt]
        end
      end

      context "when a errors is provided" do
        let(:body) { error_body }

        it "is expected to set errors" do
          expect { response.process_body }.to change(response, :errors).to body[:errors]
        end
      end

      it "is expected to call Oj.load" do
        allow(Oj).to receive(:load).and_call_original
        response.process_body
        expect(Oj).to have_received(:load)
      end

      it "is expected to set status" do
        expect { response.process_body }.to change(response, :status).to body[:status]
      end

      it "is expected to set request" do
        expect { response.process_body }.to change(response, :request).to body[:request]
      end
    end

    describe '::process_headers' do
      it "is expected to set limit to X-Limit-App-Limit" do
        expect { response.process_headers }.to change(response, :limit).to headers[:'X-Limit-App-Limit']
      end

      it "is expected to set remaing to X-Limit-App-Remaining" do
        expect { response.process_headers }.to change(response, :remaining).to headers[:'X-Limit-App-Remaining']
      end

      it "is expected to set reset to X-Limit-App-Reset" do
        expect { response.process_headers }.to change(response, :reset).to headers[:'X-Limit-App-Reset']
      end
    end
  end
end
