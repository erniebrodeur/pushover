require 'spec_helper'

module Pushover
  describe Response do
    let(:body) { { "status": 1, "request": "647d2300-702c-4b38-8b2f-d56326ae460b" } }
    let(:error_body) { { "user": "invalid", "errors": ["user identifier is invalid"], "status": 0, "request": "5042853c-402d-4a18-abcb-168734a801de" } }
    let(:headers) do
      {
        "X-Limit-App-Limit":     7500,
        "X-Limit-App-Remaining": 7496,
        "X-Limit-App-Reset":     1_393_653_600
      }
    end

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
      it { is_expected.to have_attributes(user: nil) }
    end

    describe "Instance Signatures" do
      it { is_expected.to respond_to(:original=).with(1).argument }
      it { is_expected.to respond_to(:process).with(0).argument }
      it { is_expected.to respond_to(:process_body).with(0).argument }
      it { is_expected.to respond_to(:process_headers).with(0).argument }
    end

    describe '::original=' do
      context "when the argument is not an Excon::Response" do
        it "is expected to raise argument error"
      end

      it "is expected to set @original the argument"
    end

    describe '::process' do
      it "is expected to call process_body"
      it "is expected to call process_headers"
    end

    describe '::process_body' do
      it "is expected to set errors"
      it "is expected to set original"
      it "is expected to set receipt"
      it "is expected to set request"
      it "is expected to set status"
      it "is expected to set user"
    end

    describe '::process_headers' do
      it "is expected to set limit to X-Limit-App-Limit"
      it "is expected to set remaing to X-Limit-App-Remaining"
      it "is expected to set reset to X-Limit-App-Reset"
    end
  end
end
