require 'spec_helper'
#
# it { is_expected.to have_attributes(state: a_kind_of(Symbol)) }
# it { is_expected.to have_attributes(user: nil) }
# it { is_expected.to have_attributes(schema: current_schema) }

module Pushover
  describe Message do
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
    end

    describe ".send" do
    end

    # specify { expect(described_class).to respond_to(:image_deployable?).with(1).arguments }
  end
end
