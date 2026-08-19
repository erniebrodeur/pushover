require 'spec_helper'

describe Pushover::Users do
  subject(:users) { Pushover::Client.new(token: 'app-token').users }

  let(:user) { 'u' * 30 }

  after { Excon.stubs.clear }

  describe '#validate' do
    context 'with a valid user and device' do
      let(:request) { {} }
      let(:response) { users.validate(user: user, device: 'phone-1') }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/users/validate.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump(
              'status' => 1, 'request' => 'request-id', 'devices' => ['phone-1'], 'licenses' => ['Android']
            ),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'posts the token, user, and device as JSON' do
        response

        expect(Oj.strict_load(request[:body])).to eq(
          'token' => 'app-token', 'user' => user, 'device' => 'phone-1'
        )
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns active devices and licensed platforms' do
        expect(response.attributes).to eq('devices' => ['phone-1'], 'licenses' => ['Android'])
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    context 'without a device' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/users/validate.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
        end

        users.validate(user: user)
      end

      it 'omits the device from the JSON body' do
        expect(Oj.strict_load(request[:body])).to eq('token' => 'app-token', 'user' => user)
      end
    end

    context 'when Pushover rejects the user' do
      let(:response) { users.validate(user: user) }

      before do
        Excon.stub(method: :post, path: '/1/users/validate.json') do |_params|
          {
            body:   Oj.dump('status' => 0, 'errors' => ['user identifier is invalid'], 'user' => 'invalid'),
            status: 400
          }
        end
      end

      it 'returns errors from the 4xx response' do
        expect(response).to have_attributes(status: 0, errors: ['user identifier is invalid'])
      end

      it 'preserves endpoint-specific error details' do
        expect(response.attributes).to eq('user' => 'invalid')
      end
    end

    [nil, ''].each do |invalid_user|
      it 'requires a user or group identifier' do
        expect { users.validate(user: invalid_user) }.to raise_error ArgumentError, /user must be supplied/
      end
    end

    [123, 'u' * 29, 'u' * 31, "#{'u' * 29}-"].each do |invalid_user|
      it 'requires a 30-character alphanumeric user or group identifier' do
        expect { users.validate(user: invalid_user) }
          .to raise_error ArgumentError, /user must be 30 alphanumeric characters/
      end
    end

    ['', 123, 'a' * 26, 'invalid device'].each do |invalid_device|
      it 'validates an optional device name' do
        expect { users.validate(user: user, device: invalid_device) }
          .to raise_error ArgumentError, /device must be 1 to 25 letters, numbers, underscores, or hyphens/
      end
    end
  end
end
