require 'spec_helper'

module Pushover
  describe Api do
    metadata[:api_messages] = %i(messages sounds limits validate receipts)

    describe "#endpoints" do
      specify { expect(described_class).to respond_to(:endpoints).with(0).arguments }
      let(:result) { described_class.endpoints }

      it "is expected to return a hash" do
        expect(result).to be_a Hash
      end

      metadata[:api_messages].each do |endpoint|
        it "is expected to have #{endpoint} as a key" do
          expect(result[endpoint]).not_to be_nil
        end
      end

      it "is expected to have a uri as the value"
    end

    describe "#endpoint" do
      specify { expect(described_class).to respond_to(:endpoint).with(1).arguments }

      it "is expected to respond to :messages as the param"
      it "is expected to respond to :sounds as the param"
      it "is expected to respond to :limits as the param"
      it "is expected to respond to :validate as the param"
      it "is expected to respond to :receipts as the param"

      context "when it is not a valid endpoint as the param" do
        it "is expected to return nil"
      end

      it "is expected to return a URL endpoint"
    end

    describe "#post" do
      it "is expected to post a notification to pushover"
      it "is expected to process the notification response"
      it "is expected to return a response object"

      context "when the response is 4xx" do
        it "is expected to raise an exception"
      end

      context "when the response is 5xx" do
        it "is expected to raise an exception"
      end
    end
  end
end
