require 'spec_helper'

describe Pushover::Receipt do
  let(:params) { { 'token' => 't', 'key' => 'k', 'message' => 'message' } }

  it { is_expected.to respond_to(:push).with(0).argument }

  describe "#push" do
    let(:subject) { described_class.new(params).push }

    it { is_expected }

    ['token', 'key', 'message'].each do |param|
      context "when #{param} is not supplied" do
        before { params.delete param }

        it { expect { subject }.to raise_error RuntimeError, /#{param} must be supplied/ }
      end
    end
  end
end
