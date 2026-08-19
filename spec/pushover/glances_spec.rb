require 'spec_helper'

describe Pushover::Glances do
  subject(:glances) { Pushover::Client.new(token: 'app-token').glances }

  let(:user) { 'u' * 30 }

  after { Excon.stubs.clear }

  describe '#update' do
    context 'with a complete update' do
      let(:request) { {} }
      let(:response) do
        glances.update(
          user: user, device: 'watch-1', title: 'Sales', text: '30', subtext: 'Today', count: -3, percent: 42
        )
      end
      let(:expected_body) do
        {
          'token'   => 'app-token',
          'user'    => user,
          'device'  => 'watch-1',
          'title'   => 'Sales',
          'text'    => '30',
          'subtext' => 'Today',
          'count'   => -3,
          'percent' => 42
        }
      end

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/glances.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id'),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'posts all fields as JSON' do
        response

        expect(Oj.strict_load(request[:body])).to eq(expected_body)
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id', attributes: {})
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    it 'only sends fields being updated and preserves a blank value used to clear data' do
      request = capture_successful_request
      glances.update(user: user, title: '')

      expect(Oj.strict_load(request[:body])).to eq('token' => 'app-token', 'user' => user, 'title' => '')
    end

    it 'allows numeric fields to be cleared with blank values' do
      request = capture_successful_request
      glances.update(user: user, count: '', percent: '')

      expect(Oj.strict_load(request[:body])).to include('count' => '', 'percent' => '')
    end

    it 'accepts a blank device to target all registered widgets' do
      request = capture_successful_request
      glances.update(user: user, device: '', text: 'Garage open')

      expect(Oj.strict_load(request[:body])).to include('device' => '')
    end

    context 'when Pushover rejects the update' do
      let(:response) { glances.update(user: user, text: 'Garage open') }

      before do
        Excon.stub(
          { method: :post, path: '/1/glances.json' },
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

    [nil, ''].each do |invalid_user|
      it 'requires a user identifier' do
        expect { glances.update(user: invalid_user, text: 'Garage open') }
          .to raise_error ArgumentError, /user must be supplied/
      end
    end

    [123, 'u' * 29, 'u' * 31, "#{'u' * 29}-"].each do |invalid_user|
      it 'requires a 30-character alphanumeric user identifier' do
        expect { glances.update(user: invalid_user, text: 'Garage open') }
          .to raise_error ArgumentError, /user must be 30 alphanumeric characters/
      end
    end

    it 'requires at least one data field' do
      expect { glances.update(user: user, device: 'watch-1') }
        .to raise_error ArgumentError, /at least one glance data field must be supplied/
    end

    it 'treats nil data fields as omitted' do
      expect { glances.update(user: user, text: nil) }
        .to raise_error ArgumentError, /at least one glance data field must be supplied/
    end

    it 'rejects unsupported parameters' do
      expect { glances.update(user: user, text: 'Garage open', priority: 1) }
        .to raise_error ArgumentError, /unsupported glance parameter: priority/
    end

    %i[title text subtext].each do |field|
      it "requires #{field} to be a string" do
        expect { glances.update(user: user, field => 123) }
          .to raise_error ArgumentError, /#{field} must be a String/
      end

      it "limits #{field} to 100 characters" do
        expect { glances.update(user: user, field => 'a' * 101) }
          .to raise_error ArgumentError, /#{field} must be at most 100 characters/
      end
    end

    it 'counts multibyte text limits by characters' do
      stub_success

      expect { glances.update(user: user, text: 'é' * 100) }.not_to raise_error
    end

    it 'accepts a negative integer count' do
      stub_success

      expect { glances.update(user: user, count: -1) }.not_to raise_error
    end

    ['1', 1.5, true].each do |invalid_count|
      it 'requires count to be an integer or blank' do
        expect { glances.update(user: user, count: invalid_count) }
          .to raise_error ArgumentError, /count must be an Integer or blank/
      end
    end

    [0, 100].each do |valid_percent|
      it "accepts percent #{valid_percent}" do
        stub_success

        expect { glances.update(user: user, percent: valid_percent) }.not_to raise_error
      end
    end

    [-1, 101, '50', 50.5].each do |invalid_percent|
      it 'requires percent to be an integer from 0 to 100 or blank' do
        expect { glances.update(user: user, percent: invalid_percent) }
          .to raise_error ArgumentError, /percent must be an Integer from 0 to 100 or blank/
      end
    end

    [123, 'a' * 26, 'invalid device', 'watch,phone'].each do |invalid_device|
      it 'validates a nonblank device name' do
        expect { glances.update(user: user, device: invalid_device, text: 'Garage open') }
          .to raise_error ArgumentError, /device must be blank or 1 to 25 letters, numbers, underscores, or hyphens/
      end
    end

    def stub_success
      Excon.stub(
        { method: :post, path: '/1/glances.json' },
        { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
      )
    end

    def capture_successful_request
      request = {}
      captured_request = request
      Excon.stub(method: :post, path: '/1/glances.json') do |params|
        captured_request.replace(params)
        { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
      end
      request
    end
  end
end
