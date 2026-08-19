require 'open3'
require 'rbconfig'
require 'spec_helper'

describe Pushover::Receipt do
  subject(:legacy_receipt) { described_class.new(receipt: receipt, token: token) }

  let(:receipt) { 'r' * 30 }
  let(:token) { 'app-token' }
  let(:standalone_script) do
    <<~'RUBY'
      require 'excon'
      Excon.defaults[:mock] = true
      require 'pushover/receipt'
      receipt = 'r' * 30
      Excon.stub(method: :get, path: "/1/receipts/#{receipt}.json", query: { token: 'app-token' }) do
        { body: Oj.dump('status' => 1), status: 200 }
      end
      abort unless Pushover::Receipt.new(token: 'app-token', receipt: receipt).get.status == 1
    RUBY
  end

  after { Excon.stubs.clear }

  it 'supports the standalone legacy require path' do
    _stdout, stderr, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', standalone_script)

    expect(status).to be_success, stderr
  end

  it 'uses an explicit compatibility class' do
    expect(described_class.superclass).to eq(Object)
  end

  it 'accepts the legacy keyword form' do
    instance = described_class.new(receipt: receipt, token: token)

    expect(instance).to have_attributes(receipt: receipt, token: token)
  end

  it 'accepts a single Hash with string keys' do
    instance = described_class.new('receipt' => receipt, 'token' => token)

    expect(instance).to have_attributes(receipt: receipt, token: token)
  end

  it 'keeps the legacy members writable' do
    legacy_receipt.receipt = 'a' * 30

    expect(legacy_receipt.receipt).to eq('a' * 30)
  end

  it 'rejects unknown members' do
    expect { described_class.new(unknown: 'value') }.to raise_error ArgumentError
  end

  it 'rejects non-Hash positional attributes' do
    [nil, false, 1, 'invalid'].each do |attributes|
      expect { described_class.new(attributes) }.to raise_error ArgumentError, /attributes must be supplied as a Hash/
    end
  end

  it { is_expected.to respond_to(:get).with(0).arguments }

  describe '#get' do
    before { allow(Warning).to receive(:warn) }

    context 'with a valid receipt' do
      let(:request) { {} }
      let(:response) { legacy_receipt.get }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   "/1/receipts/#{receipt}.json",
          query:  { token: token },
          body:   nil
        ) do |request_params|
          captured_request.replace(request_params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'acknowledged' => 0),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'delegates to the shared receipt endpoint' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: "/1/receipts/#{receipt}.json", query: "token=#{token}"
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns the shared response' do
        expect(response).to have_attributes(status: 1, request: 'request-id', attributes: { 'acknowledged' => 0 })
      end

      it 'emits the exact migration warning once' do
        response

        expect(Warning).to have_received(:warn).with(
          a_string_including('Pushover::Receipt#get is deprecated; use Pushover::Client.new(token: ...).receipts.get(receipt: ...)'),
          category: nil
        ).once
      end
    end

    %i[receipt token].each do |parameter|
      it "preserves the legacy missing-#{parameter} error" do
        instance = described_class.new(receipt: receipt, token: token)
        instance.public_send("#{parameter}=", nil)

        expect { instance.get }.to raise_error RuntimeError, "#{parameter} must be supplied"
      end
    end

    it 'applies current receipt validation after the legacy presence checks' do
      instance = described_class.new(receipt: 'receipt', token: token)

      expect { instance.get }.to raise_error ArgumentError, /receipt must be 30 alphanumeric characters/
    end
  end
end
