require 'spec_helper'

describe Pushover::Sounds do
  subject(:sounds) { Pushover::Client.new(token: 'app-token').sounds }

  let(:available_sounds) do
    {
      'pushover'     => 'Pushover (default)',
      'bike'         => 'Bike',
      'custom-alert' => 'Custom Alert'
    }
  end

  after { Excon.stubs.clear }

  describe '#get' do
    context 'when Pushover returns available sounds' do
      let(:request) { {} }
      let(:response) { sounds.get }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   '/1/sounds.json',
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'sounds' => available_sounds),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'gets sounds with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: '/1/sounds.json', query: 'token=app-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns built-in and custom sounds' do
        expect(response.attributes).to eq('sounds' => available_sounds)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    context 'when Pushover rejects the application token' do
      before do
        Excon.stub(
          { method: :get, path: '/1/sounds.json', query: { token: 'app-token' }, body: nil },
          {
            body:   Oj.dump(
              'status'  => 0,
              'request' => 'request-id',
              'errors'  => ['application token is invalid'],
              'token'   => 'invalid'
            ),
            status: 400
          }
        )
      end

      it 'returns errors from a 4xx response' do
        response = sounds.get

        expect(response).to have_attributes(status: 0, errors: ['application token is invalid'])
      end

      it 'preserves endpoint-specific error details' do
        expect(sounds.get.attributes).to eq('token' => 'invalid')
      end
    end
  end
end
