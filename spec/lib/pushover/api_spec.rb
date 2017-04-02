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

    describe "#post" do
      specify { expect(described_class).to respond_to(:post).with(2).argument }

      it "is expected to accept an endpoint symbol as the first param"
      it "is expected to accept a hash as the second param"
      it "is expected to call Excon.post to post remotely"
      it "is expected to return a response object"

      context "when the argument is not a hash" do
        it "is expected to raise an ArgumentError exception with message /hash/"
      end

      context "when the response is 4xx" do
        it "is expected to raise an exception"
      end

      context "when the response is 5xx" do
        it "is expected to raise an exception"
      end
    end
  end
end
