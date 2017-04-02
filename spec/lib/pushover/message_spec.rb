require 'spec_helper'

module Pushover
  describe Message do
    # let(:param_list) do
    #   [
    #     'message',
    #     'title',
    #     'token',
    #     'user',
    #     'device',
    #     'url',
    #     'url_title',
    #     'priority',
    #     'timestamp',
    #     'sound'
    #   ]
    # end

    it { is_expected.to have_attributes(token: a_kind_of(String)) }
    it { is_expected.to have_attributes(user: a_kind_of(String)) }
    it { is_expected.to have_attributes(device: a_kind_of(String)) }
    it { is_expected.to have_attributes(title: a_kind_of(String)) }
    it { is_expected.to have_attributes(message: a_kind_of(String)) }
    it { is_expected.to have_attributes(timestamp: a_kind_of(DateTime)) }
    it { is_expected.to have_attributes(priority: a_kind_of(String)) }
    it { is_expected.to have_attributes(url: a_kind_of(String)) }
    it { is_expected.to have_attributes(url_title: a_kind_of(String)) }
    it { is_expected.to have_attributes(sound: a_kind_of(String)) }

    describe "#create" do
      # specify { expect(described_class).to respond_to(:image_deployable?).with(1).arguments }

      it "will return a new message object"
    end

    describe ".post" do
      it "will return a new response object"

      it "will call Api::post with to_hash"

      context "when the argument includes a param that is not valid" do
        it "is expected to raise a RuntimeError exception with message /param/"
      end
    end
  end
end
