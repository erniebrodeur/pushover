require 'base64'
require 'spec_helper'

describe Pushover::Messages do
  subject(:messages) { Pushover::Client.new(token: 'app-token').messages }

  after { Excon.stubs.clear }

  describe '#create' do
    context 'with a valid message' do
      let(:request) { {} }
      let(:response) { messages.create(user: 'user-key', message: 'Hello', title: 'Greeting', html: true) }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/messages.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump(status: 1, request: 'request-id'), headers: { 'X-Limit-App-Remaining' => '9' }, status: 200 }
        end
      end

      it 'posts all fields as JSON' do
        response

        expect(Oj.load(request[:body])).to eq(
          token: 'app-token', user: 'user-key', message: 'Hello', title: 'Greeting', html: 1
        )
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns a response' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    it 'returns Pushover errors from a 4xx response' do
      Excon.stub(method: :post, path: '/1/messages.json') do |_params|
        { body: Oj.dump(status: 0, errors: ['user identifier is invalid']), status: 400 }
      end

      response = messages.create(user: 'invalid', message: 'Hello')

      expect(response).to have_attributes(status: 0, errors: ['user identifier is invalid'])
    end

    def stub_success
      Excon.stub(
        { method: :post, path: '/1/messages.json' },
        { body: Oj.dump(status: 1, request: 'request-id'), status: 200 }
      )
    end

    %i[user message].each do |parameter|
      it "requires #{parameter}" do
        params = { user: 'user-key', message: 'Hello' }
        params[parameter] = ''

        expect { messages.create(**params) }.to raise_error ArgumentError, /#{parameter} must be supplied/
      end
    end

    {
      message:   1024,
      title:     250,
      url:       512,
      url_title: 100
    }.each do |parameter, maximum|
      it "limits #{parameter} to #{maximum} characters" do
        params = { user: 'user-key', message: 'Hello', parameter => 'a' * (maximum + 1) }

        expect { messages.create(**params) }.to raise_error ArgumentError, /#{parameter} must be at most #{maximum} characters/
      end
    end

    it 'limits one request to 50 users' do
      users = Array.new(51, 'user-key').join(',')

      expect { messages.create(user: users, message: 'Hello') }.to raise_error ArgumentError, /at most 50 users/
    end

    it 'validates device names' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', device: 'not a valid device')
      end.to raise_error ArgumentError, /device contains an invalid name/
    end

    it 'accepts only documented priorities' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', priority: 3)
      end.to raise_error ArgumentError, /priority must be one of/
    end

    it 'requires retry and expire for emergency priority' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', priority: 2)
      end.to raise_error ArgumentError, /retry and expire must be supplied/
    end

    it 'requires emergency retries of at least 30 seconds' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', priority: 2, retry: 29, expire: 10_801)
      end.to raise_error ArgumentError, /retry must be at least 30 seconds/
    end

    it 'limits emergency expiration to 10800 seconds' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', priority: 2, retry: 30, expire: 10_801)
      end.to raise_error ArgumentError, /expire must be at most 10800 seconds/
    end

    it 'rejects emergency-only fields for other priorities' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', callback: 'https://example.test/callback')
      end.to raise_error ArgumentError, /callback is only valid with priority 2/
    end

    it 'requires an HTTP or HTTPS callback URL' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', priority: 2, retry: 30, expire: 60, callback: 'file:///tmp/callback')
      end.to raise_error ArgumentError, /callback must be an HTTP or HTTPS URL/
    end

    it 'does not allow HTML and monospace formatting together' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', html: true, monospace: true)
      end.to raise_error ArgumentError, /html and monospace cannot both be enabled/
    end

    it 'requires a positive TTL' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', ttl: 0)
      end.to raise_error ArgumentError, /ttl must be a positive integer/
    end

    it 'requires valid Base64 attachment data' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', attachment_base64: 'not-base64', attachment_type: 'image/png')
      end.to raise_error ArgumentError, /attachment_base64 must be valid Base64/
    end

    it 'limits decoded attachments to 5 MiB' do
      oversized = Base64.strict_encode64('a' * 5_242_881)

      expect do
        messages.create(user: 'user-key', message: 'Hello', attachment_base64: oversized, attachment_type: 'image/png')
      end.to raise_error ArgumentError, /attachment must not exceed 5242880 bytes/
    end

    it 'requires attachment data and MIME type together' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', attachment_base64: Base64.strict_encode64('image'))
      end.to raise_error ArgumentError, /attachment_type must be supplied/
    end

    context 'with end-to-end encryption' do
      let(:request) { {} }
      let(:key) { '00' * 32 }

      before do
        captured_request = request
        allow(SecureRandom).to receive(:random_bytes).and_return("\x01" * 16)
        Excon.stub(method: :post, path: '/1/messages.json') do |params|
          captured_request.replace(Oj.load(params[:body]))
          { body: Oj.dump(status: 1, request: 'request-id'), status: 200 }
        end
        messages.create(user: 'user-key', message: 'secret', title: 'private', encryption_key: key)
      end

      it 'uses the documented deterministic wire format' do
        expect(request.slice(:encrypted, :message, :title)).to eq(
          encrypted: 1,
          message:   'AQEBAQEBAQEBAQEBAQEBAU0FqlkYIHEPzHs0NklFY9QT8ZekMQAM/J6iku1rmOJcEcm1SgT5ASVxoQW5SUFLnyWhe0y1Tp7q0YmS2iTpk4k=',
          title:     'AQEBAQEBAQEBAQEBAQEBAWWaD5zPUESFUncs7Hm+DBMTqpHx+n5zEHeQcvJiY+/LX/xd2rJVGXcosjBT23uEQ1TagEXt9wehyXozQxxYguw='
        )
      end
    end

    it 'requires a 64-character hexadecimal encryption key' do
      expect do
        messages.create(user: 'user-key', message: 'Hello', encryption_key: 'invalid')
      end.to raise_error ArgumentError, /encryption_key must be 64 hexadecimal characters/
    end
  end
end
