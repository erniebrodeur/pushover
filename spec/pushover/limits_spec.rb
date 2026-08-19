require 'spec_helper'

describe Pushover::Limits do
  subject(:limits) { Pushover::Client.new(token: 'app-token').limits }

  let(:usage_limits) do
    {
      'limit'     => 10_000,
      'remaining' => 7_496,
      'reset'     => 1_393_653_600
    }
  end

  after { Excon.stubs.clear }

  describe '#get' do
    context 'when Pushover returns account usage limits' do
      let(:request) { {} }
      let(:response) { limits.get }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   '/1/apps/limits.json',
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump({ 'status' => 1, 'request' => 'request-id' }.merge(usage_limits)),
            headers: { 'X-Limit-App-Remaining' => '7496' },
            status:  200
          }
        end
      end

      it 'gets limits with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: '/1/apps/limits.json', query: 'token=app-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns the account usage limit, remaining messages, and reset time' do
        expect(response.attributes).to eq(usage_limits)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '7496')
      end
    end

    context 'when Pushover rejects the application token' do
      before do
        Excon.stub(
          { method: :get, path: '/1/apps/limits.json', query: { token: 'app-token' }, body: nil },
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
        response = limits.get

        expect(response).to have_attributes(status: 0, errors: ['application token is invalid'])
      end

      it 'preserves endpoint-specific error details' do
        expect(limits.get.attributes).to eq('token' => 'invalid')
      end
    end
  end
end
