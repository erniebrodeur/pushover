require 'spec_helper'

describe Pushover::Licenses do
  subject(:licenses) { Pushover::Client.new(token: 'app-token').licenses }

  let(:user) { 'u' * 30 }

  after { Excon.stubs.clear }

  describe '#get' do
    context 'when Pushover returns available license credits' do
      let(:request) { {} }
      let(:response) { licenses.get }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   '/1/licenses.json',
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'credits' => 5),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'gets credits with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: '/1/licenses.json', query: 'token=app-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns response metadata and available credits' do
        expect(response).to have_attributes(
          status: 1, request: 'request-id', attributes: { 'credits' => 5 }
        )
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    context 'when Pushover rejects the application token' do
      before do
        Excon.stub(
          { method: :get, path: '/1/licenses.json', query: { token: 'app-token' }, body: nil },
          {
            body:   Oj.dump(
              'status'  => 0,
              'request' => 'request-id',
              'errors'  => { 'token' => ['is invalid'] }
            ),
            status: 400
          }
        )
      end

      it 'preserves structured licensing errors' do
        expect(licenses.get).to have_attributes(
          status: 0, request: 'request-id', errors: { 'token' => ['is invalid'] }
        )
      end
    end
  end

  describe '#assign' do
    context 'with a user key and operating system' do
      let(:request) { {} }
      let(:response) { licenses.assign(user: user, os: 'Android') }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/licenses/assign.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id', 'credits' => 4),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'posts one non-idempotent request to the assignment endpoint' do
        response

        expect(request.slice(:method, :path, :idempotent)).to eq(
          method: :post, path: '/1/licenses/assign.json', idempotent: false
        )
      end

      it 'serializes the application token and assignment fields with string keys' do
        response

        expect(Oj.strict_load(request[:body])).to eq(
          'token' => 'app-token', 'user' => user, 'os' => 'Android'
        )
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata, remaining credits, and headers' do
        expect(response).to have_attributes(
          status: 1, request: 'request-id', attributes: { 'credits' => 4 }, headers: include('X-Request-Id' => 'header-id')
        )
      end
    end

    context 'with an email address' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/licenses/assign.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id', 'credits' => 4), status: 200 }
        end

        licenses.assign(email: 'person@example.test')
      end

      it 'omits the user and operating system fields' do
        expect(Oj.strict_load(request[:body])).to eq(
          'token' => 'app-token', 'email' => 'person@example.test'
        )
      end
    end

    context 'with both recipient identifiers' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/licenses/assign.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id', 'credits' => 4), status: 200 }
        end

        licenses.assign(user: user, email: 'person@example.test')
      end

      it 'does not invent a mutual-exclusion rule' do
        expect(Oj.strict_load(request[:body])).to include(
          'user' => user, 'email' => 'person@example.test'
        )
      end
    end

    context 'with a blank operating system' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/licenses/assign.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id', 'credits' => 4), status: 200 }
        end

        licenses.assign(user: user, os: '')
      end

      it 'preserves the documented first-platform selection' do
        expect(Oj.strict_load(request[:body])).to include('os' => '')
      end
    end

    context 'when Pushover rejects the assignment' do
      before do
        Excon.stub(
          { method: :post, path: '/1/licenses/assign.json' },
          {
            body:   Oj.dump(
              'status'  => 0,
              'request' => 'request-id',
              'errors'  => { 'token' => ['is out of available license credits'] }
            ),
            status: 400
          }
        )
      end

      it 'returns structured errors without retrying or flattening them' do
        expect(licenses.assign(user: user)).to have_attributes(
          status:  0,
          request: 'request-id',
          errors:  { 'token' => ['is out of available license credits'] }
        )
      end
    end

    it 'requires a user key or email address' do
      expect { licenses.assign }.to raise_error ArgumentError, /user or email must be supplied/
    end

    it 'validates a supplied blank user key' do
      expect { licenses.assign(user: '', email: 'person@example.test') }
        .to raise_error ArgumentError, /user must be supplied/
    end

    ['u' * 29, 'u' * 31, "#{'u' * 29}-", 123].each do |invalid_user|
      it 'requires a 30-character alphanumeric user key' do
        expect { licenses.assign(user: invalid_user) }
          .to raise_error ArgumentError, /user must be 30 alphanumeric characters/
      end
    end

    ['', '   ', 123].each do |invalid_email|
      it 'requires a supplied email address to be a nonblank string' do
        expect { licenses.assign(email: invalid_email) }
          .to raise_error ArgumentError, /email must be a nonblank String/
      end
    end

    ['android', 'IOS', 'Windows', 123].each do |invalid_os|
      it 'accepts only documented operating systems' do
        expect { licenses.assign(user: user, os: invalid_os) }
          .to raise_error ArgumentError, /os must be blank, Android, iOS, or Desktop/
      end
    end
  end
end
