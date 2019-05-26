require 'spec_helper'

describe Pushover::Message do
  it { is_expected.to have_attributes(token: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(user: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(message: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(attachment: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(device: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(title: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(url: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(url_title: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(priority: a_kind_of(Numeric).or(be_nil)) }
  it { is_expected.to have_attributes(sound: a_kind_of(String).or(be_nil)) }
  it { is_expected.to have_attributes(timestamp: a_kind_of(DateTime).or(be_nil)) }
  it { is_expected.to have_attributes(expire: a_kind_of(Numeric).or(be_nil)) }
  it { is_expected.to have_attributes(retry: a_kind_of(Numeric).or(be_nil)) }
  it { is_expected.to have_attributes(callback: a_kind_of(String).or(be_nil)) }

  it { is_expected.to respond_to(:push).with(0).argument }

  describe "#push" do
    let(:params) { { 'token' => 't', 'user' => 'u', 'message' => 'message' } }

    it "is expected to send" do
      expect { described_class.new(params).push }.to raise_error Excon::Error::StubNotFound
    end

    ['token', 'user', 'message'].each do |param|
      context "when #{param} is not supplied" do
        before { params.delete param }

        it { expect { described_class.new(params).push }.to raise_error RuntimeError, /#{param} must be supplied/ }
      end
    end
  end
end
