require 'spec_helper'

describe Pushover::Subscriptions do
  subject(:subscriptions) { Pushover::Client.new(token: 'app-token').subscriptions }

  let(:subscription) { 'Forum-f504h08fhlasdfj' }
  let(:user) { 'u' * 30 }

  after { Excon.stubs.clear }

  it 'does not expose import as a public alias' do
    expect(subscriptions).not_to respond_to(:import)
  end

  describe '#migrate' do
    context 'with all documented fields' do
      let(:request) { {} }
      let(:response) do
        subscriptions.migrate(
          subscription: subscription,
          user:         user,
          device_name:  'phone-1',
          sound:        'custom-sound'
        )
      end
      let(:expected_body) do
        {
          'token'        => 'app-token',
          'subscription' => subscription,
          'user'         => user,
          'device_name'  => 'phone-1',
          'sound'        => 'custom-sound'
        }
      end

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/subscriptions/migrate.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump(
              'status'              => 1,
              'request'             => 'request-id',
              'subscribed_user_key' => 's' * 30
            ),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'posts to the subscription migration endpoint' do
        response

        expect(request.slice(:method, :path)).to eq(
          method: :post, path: '/1/subscriptions/migrate.json'
        )
      end

      it 'serializes the application token and migration fields with string keys' do
        response

        expect(Oj.strict_load(request[:body])).to eq(expected_body)
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata and the subscribed user key' do
        expect(response).to have_attributes(
          status:     1,
          request:    'request-id',
          attributes: { 'subscribed_user_key' => 's' * 30 }
        )
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    context 'without optional fields' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/subscriptions/migrate.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
        end

        subscriptions.migrate(subscription: subscription, user: user)
      end

      it 'omits device_name and sound from the JSON body' do
        expect(Oj.strict_load(request[:body])).to eq(
          'token' => 'app-token', 'subscription' => subscription, 'user' => user
        )
      end
    end

    context 'with a blank sound' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/subscriptions/migrate.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
        end

        subscriptions.migrate(subscription: subscription, user: user, sound: '')
      end

      it 'preserves the documented default-sound selection' do
        expect(Oj.strict_load(request[:body])).to include('sound' => '')
      end
    end

    context 'when Pushover rejects the migration' do
      before do
        Excon.stub(
          { method: :post, path: '/1/subscriptions/migrate.json' },
          {
            body:   Oj.dump(
              'status'  => 0,
              'request' => 'request-id',
              'errors'  => ['subscription is invalid'],
              'user'    => 'invalid'
            ),
            status: 400
          }
        )
      end

      it 'returns API errors and preserves endpoint-specific details' do
        expect(subscriptions.migrate(subscription: subscription, user: user)).to have_attributes(
          status: 0, request: 'request-id', errors: ['subscription is invalid'], attributes: { 'user' => 'invalid' }
        )
      end
    end

    [nil, ''].each do |invalid_subscription|
      it 'requires a subscription code' do
        expect { subscriptions.migrate(subscription: invalid_subscription, user: user) }
          .to raise_error ArgumentError, /subscription must be supplied/
      end
    end

    it 'requires the subscription code to be a string' do
      expect { subscriptions.migrate(subscription: 123, user: user) }
        .to raise_error ArgumentError, /subscription must be a String/
    end

    [nil, ''].each do |invalid_user|
      it 'requires a user key' do
        expect { subscriptions.migrate(subscription: subscription, user: invalid_user) }
          .to raise_error ArgumentError, /user must be supplied/
      end
    end

    ['u' * 29, 'u' * 31, "#{'u' * 29}-", 123].each do |invalid_user|
      it 'requires a 30-character alphanumeric user key' do
        expect { subscriptions.migrate(subscription: subscription, user: invalid_user) }
          .to raise_error ArgumentError, /user must be 30 alphanumeric characters/
      end
    end

    ['', 'd' * 26, 'invalid device', 'phone,watch', 123].each do |invalid_device|
      it 'validates an optional device name' do
        expect do
          subscriptions.migrate(subscription: subscription, user: user, device_name: invalid_device)
        end.to raise_error ArgumentError, /device_name must be 1 to 25/
      end
    end

    it 'requires an optional sound to be a string' do
      expect { subscriptions.migrate(subscription: subscription, user: user, sound: 123) }
        .to raise_error ArgumentError, /sound must be a String/
    end
  end
end
