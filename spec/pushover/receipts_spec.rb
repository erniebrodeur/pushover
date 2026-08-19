require 'spec_helper'

describe Pushover::Receipts do
  subject(:receipts) { Pushover::Client.new(token: 'app-token').receipts }

  let(:receipt) { 'a' * 30 }
  let(:receipt_attributes) do
    {
      'acknowledged'           => 1,
      'acknowledged_at'        => 1_723_990_000,
      'acknowledged_by'        => 'user-key',
      'acknowledged_by_device' => 'phone',
      'last_delivered_at'      => 1_723_989_900,
      'expired'                => 0,
      'expires_at'             => 1_723_993_600,
      'called_back'            => 1,
      'called_back_at'         => 1_723_990_001
    }
  end
  let(:success_body) { { 'status' => 1, 'request' => 'request-id' }.merge(receipt_attributes) }

  after { Excon.stubs.clear }

  describe '#get' do
    context 'with a valid receipt' do
      let(:request) { {} }
      let(:response) { receipts.get(receipt: receipt) }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   "/1/receipts/#{receipt}.json",
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump(success_body),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'gets the receipt with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(method: :get, path: "/1/receipts/#{receipt}.json", query: 'token=app-token')
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns the response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns the receipt status fields' do
        expect(response.attributes).to eq(receipt_attributes)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    context 'when Pushover rejects the request' do
      before do
        Excon.stub(
          { method: :get, path: "/1/receipts/#{receipt}.json", query: { token: 'app-token' }, body: nil },
          { body: Oj.dump('status' => 0, 'errors' => ['receipt is invalid']), status: 400 }
        )
      end

      it 'returns errors from a 4xx response' do
        response = receipts.get(receipt: receipt)

        expect(response).to have_attributes(status: 0, errors: ['receipt is invalid'])
      end
    end

    it 'requires a receipt' do
      expect { receipts.get(receipt: '') }.to raise_error ArgumentError, /receipt must be supplied/
    end

    ['a' * 29, 'a' * 31, "#{'a' * 29}-"].each do |invalid_receipt|
      it 'requires exactly 30 alphanumeric characters' do
        expect { receipts.get(receipt: invalid_receipt) }
          .to raise_error ArgumentError, /receipt must be 30 alphanumeric characters/
      end
    end
  end

  describe '#cancel' do
    context 'with a valid receipt' do
      let(:request) { {} }
      let(:response) { receipts.cancel(receipt: receipt) }

      before do
        captured_request = request
        Excon.stub(method: :post, path: "/1/receipts/#{receipt}/cancel.json") do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump(status: 1, request: 'request-id'),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'posts to the receipt cancellation endpoint' do
        response

        expect(request.slice(:method, :path)).to eq(method: :post, path: "/1/receipts/#{receipt}/cancel.json")
      end

      it 'sends the application token as JSON' do
        response

        expect(Oj.strict_load(request[:body])).to eq('token' => 'app-token')
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns the response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    context 'when Pushover rejects the request' do
      before do
        Excon.stub(method: :post, path: "/1/receipts/#{receipt}/cancel.json") do |_params|
          { body: Oj.dump(status: 0, errors: ['receipt is invalid']), status: 400 }
        end
      end

      it 'returns errors from a 4xx response' do
        response = receipts.cancel(receipt: receipt)

        expect(response).to have_attributes(status: 0, errors: ['receipt is invalid'])
      end
    end

    it 'requires a receipt' do
      expect { receipts.cancel(receipt: '') }.to raise_error ArgumentError, /receipt must be supplied/
    end

    ['a' * 29, 'a' * 31, "#{'a' * 29}-"].each do |invalid_receipt|
      it 'requires exactly 30 alphanumeric characters' do
        expect { receipts.cancel(receipt: invalid_receipt) }
          .to raise_error ArgumentError, /receipt must be 30 alphanumeric characters/
      end
    end
  end

  describe '#cancel_by_tag' do
    context 'with a valid tag' do
      let(:request) { {} }
      let(:response) { receipts.cancel_by_tag(tag: 'l=chicago/ops room') }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/receipts/cancel_by_tag/l%3Dchicago%2Fops%20room.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump(status: 1, request: 'request-id'),
            headers: { 'X-Limit-App-Remaining' => '9' },
            status:  200
          }
        end
      end

      it 'posts with the tag encoded as one path segment' do
        response

        expect(request.slice(:method, :path)).to eq(
          method: :post, path: '/1/receipts/cancel_by_tag/l%3Dchicago%2Fops%20room.json'
        )
      end

      it 'sends the application token as JSON' do
        response

        expect(Oj.strict_load(request[:body])).to eq('token' => 'app-token')
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns the response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Limit-App-Remaining' => '9')
      end
    end

    context 'when Pushover rejects the request' do
      before do
        Excon.stub(method: :post, path: '/1/receipts/cancel_by_tag/l%3Dchicago%2Fops%20room.json') do |_params|
          { body: Oj.dump(status: 0, errors: ['tag is invalid']), status: 400 }
        end
      end

      it 'returns errors from a 4xx response' do
        response = receipts.cancel_by_tag(tag: 'l=chicago/ops room')

        expect(response).to have_attributes(status: 0, errors: ['tag is invalid'])
      end
    end

    it 'requires a tag' do
      expect { receipts.cancel_by_tag(tag: '') }.to raise_error ArgumentError, /tag must be supplied/
    end
  end
end
