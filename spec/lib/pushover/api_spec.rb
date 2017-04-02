require 'spec_helper'

module Pushover
  describe Api do
    describe "#endpoints" do
      it "will return an array"
      it "will equal one of: messages, sounds, limits, validate, receipt.id"
    end

    describe "#post" do
      it "will post a notification to pushover"
      it "will process the notification response"

      context "when the response is 200" do
        it "will return the response"
      end

      context "when the response is 4xx" do
        it "will raise an exception"
      end

      context "when the response is 5xx" do
        it "will raise an exception"
      end
    end
  end
end
