require 'spec_helper'

describe Pushover::Groups do
  subject(:groups) { Pushover::Client.new(token: 'app-token').groups }

  let(:group) { 'g' * 30 }

  after { Excon.stubs.clear }

  describe '#create' do
    context 'with a group name' do
      let(:request) { {} }
      let(:response) { groups.create(name: 'On-call West') }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/groups.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'group' => group),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'posts to the group creation endpoint' do
        response

        expect(request.slice(:method, :path)).to eq(method: :post, path: '/1/groups.json')
      end

      it 'posts the application token and name as JSON' do
        response

        expect(Oj.strict_load(request[:body])).to eq('token' => 'app-token', 'name' => 'On-call West')
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns the new group key' do
        expect(response.attributes).to eq('group' => group)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    context 'when Pushover rejects the request' do
      let(:response) { groups.create(name: 'On-call West') }

      before do
        Excon.stub(
          { method: :post, path: '/1/groups.json' },
          {
            body:   Oj.dump(
              'status' => 0, 'request' => 'request-id', 'errors' => ['application token is invalid']
            ),
            status: 400
          }
        )
      end

      it 'returns errors from the 400 response' do
        expect(response).to have_attributes(
          status: 0, request: 'request-id', errors: ['application token is invalid']
        )
      end
    end

    [nil, ''].each do |invalid_name|
      it 'requires a group name' do
        expect { groups.create(name: invalid_name) }.to raise_error ArgumentError, /name must be supplied/
      end
    end

    it 'requires the group name to be a string' do
      expect { groups.create(name: 123) }.to raise_error ArgumentError, /name must be a String/
    end
  end

  describe '#list' do
    context 'when the account owns groups' do
      let(:request) { {} }
      let(:listed_groups) do
        [
          { 'group' => group, 'name' => 'On-call West' },
          { 'group' => 'h' * 30, 'name' => 'Operations' }
        ]
      end
      let(:response) { groups.list }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   '/1/groups.json',
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'groups' => listed_groups),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'gets groups with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: '/1/groups.json', query: 'token=app-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns each group key and name without reordering' do
        expect(response.attributes).to eq('groups' => listed_groups)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    context 'when the account has no groups' do
      before do
        Excon.stub(
          { method: :get, path: '/1/groups.json', query: { token: 'app-token' }, body: nil },
          { body: Oj.dump('status' => 1, 'request' => 'request-id', 'groups' => []), status: 200 }
        )
      end

      it 'returns an empty groups array' do
        expect(groups.list.attributes).to eq('groups' => [])
      end
    end

    context 'when Pushover rejects the request' do
      let(:response) { groups.list }

      before do
        Excon.stub(
          { method: :get, path: '/1/groups.json', query: { token: 'app-token' }, body: nil },
          {
            body:   Oj.dump(
              'status' => 0, 'request' => 'request-id', 'errors' => ['application token is invalid']
            ),
            status: 400
          }
        )
      end

      it 'returns errors from the 400 response' do
        expect(response).to have_attributes(
          status: 0, request: 'request-id', errors: ['application token is invalid']
        )
      end
    end
  end
end
