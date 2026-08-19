require 'open3'
require 'rbconfig'
require 'spec_helper'

describe Pushover::Message do
  subject(:legacy_message) { described_class.new(params) }

  let(:params) { { token: 'app-token', user: 'user-key', message: 'Hello' } }
  let(:standalone_script) do
    <<~RUBY
      require 'excon'
      Excon.defaults[:mock] = true
      require 'pushover/message'
      Excon.stub(method: :post, path: '/1/messages.json') { { body: Oj.dump('status' => 1), status: 200 } }
      abort unless Pushover::Message.new(token: 'app-token', user: 'user-key', message: 'Hello').push.status == 1
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
    message = described_class.new(token: 'app-token', user: 'user-key', message: 'Hello')

    expect(message).to have_attributes(token: 'app-token', user: 'user-key', message: 'Hello')
  end

  it 'accepts a single Hash with string keys' do
    message = described_class.new('token' => 'app-token', 'user' => 'user-key', 'message' => 'Hello')

    expect(message).to have_attributes(token: 'app-token', user: 'user-key', message: 'Hello')
  end

  it 'keeps the legacy members writable' do
    legacy_message.title = 'Updated'

    expect(legacy_message.title).to eq('Updated')
  end

  it 'rejects unknown members' do
    expect { described_class.new(unknown: 'value') }.to raise_error ArgumentError
  end

  it 'rejects non-Hash positional attributes' do
    [nil, false, 1, 'invalid'].each do |attributes|
      expect { described_class.new(attributes) }.to raise_error ArgumentError, /attributes must be supplied as a Hash/
    end
  end

  it { is_expected.to respond_to(:push).with(0).arguments }

  describe '#push' do
    before { allow(Warning).to receive(:warn) }

    context 'with supported legacy fields' do
      let(:request) { {} }
      let(:response) { legacy_message.push }
      let(:params) do
        {
          token:     'app-token',
          user:      'user-key',
          message:   'Hello',
          device:    'phone-1',
          title:     'Greeting',
          url:       'https://example.test/details',
          url_title: 'Details',
          priority:  2,
          sound:     'siren',
          timestamp: 1_723_990_000,
          expire:    60,
          retry:     30,
          callback:  'https://example.test/callback'
        }
      end

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/messages.json') do |request_params|
          captured_request.replace(request_params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id'),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'delegates to the shared message endpoint' do
        response

        expect(request.slice(:method, :path)).to eq(method: :post, path: '/1/messages.json')
      end

      it 'serializes supported fields through the shared resource' do
        response
        expected = params.except(:token).transform_keys(&:to_s).merge('token' => 'app-token')

        expect(Oj.strict_load(request[:body])).to eq(expected)
      end

      it 'uses the shared JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns the shared response' do
        expect(response).to have_attributes(
          status: 1, request: 'request-id', headers: include('X-Limit-App-Remaining' => '9')
        )
      end

      it 'emits the exact migration warning once' do
        response

        expect(Warning).to have_received(:warn).with(
          a_string_including('Pushover::Message#push is deprecated; use Pushover::Client.new(token: ...).messages.create(...)'),
          category: nil
        ).once
      end
    end

    it 'returns Pushover errors from the shared resource' do
      Excon.stub(method: :post, path: '/1/messages.json') do |_request_params|
        { body: Oj.dump('status' => 0, 'errors' => ['user identifier is invalid']), status: 400 }
      end

      expect(legacy_message.push).to have_attributes(status: 0, errors: ['user identifier is invalid'])
    end

    %i[token user message].each do |parameter|
      it "preserves the legacy missing-#{parameter} error" do
        instance = described_class.new(params.except(parameter))

        expect { instance.push }.to raise_error RuntimeError, "#{parameter} must be supplied"
      end
    end

    ['', 'raw attachment'].each do |attachment|
      it 'rejects a non-nil raw attachment explicitly' do
        instance = described_class.new(params.merge(attachment: attachment))

        expect { instance.push }.to raise_error ArgumentError, /raw attachment is unsupported/
      end
    end
  end
end
