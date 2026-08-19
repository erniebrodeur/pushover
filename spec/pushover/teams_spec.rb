require 'spec_helper'

describe Pushover::Teams do
  subject(:teams) { Pushover::Client.new(token: 'team-token').teams }

  after { Excon.stubs.clear }

  describe '#get' do
    context 'when Pushover returns team information' do
      let(:request) { {} }
      let(:response) { teams.get }
      let(:team_attributes) do
        {
          'name'  => 'Operations',
          'users' => [
            {
              'id'            => 'member-id',
              'name'          => 'Team Member',
              'email'         => 'member@example.test',
              'administrator' => true,
              'devices'       => [
                {
                  'name'                      => 'iphone',
                  'os'                        => 'iOS',
                  'os_version'                => '26',
                  'enabled'                   => true,
                  'administratively_disabled' => false
                }
              ]
            }
          ]
        }
      end

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   '/1/teams.json',
          query:  { token: 'team-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump({ 'status' => 1, 'request' => 'request-id' }.merge(team_attributes)),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'gets the team with the team token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: '/1/teams.json', query: 'token=team-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'preserves the team, users, and nested devices' do
        expect(response).to have_attributes(
          status: 1, request: 'request-id', headers: include('X-Request-Id' => 'header-id'), attributes: team_attributes
        )
      end
    end

    context 'when Pushover rejects the team token' do
      before do
        Excon.stub(
          { method: :get, path: '/1/teams.json', query: { token: 'team-token' }, body: nil },
          {
            body:   Oj.dump('status' => 0, 'request' => 'request-id', 'errors' => ['team token is invalid']),
            status: 400
          }
        )
      end

      it 'returns errors from the 400 response' do
        expect(teams.get).to have_attributes(
          status: 0, request: 'request-id', errors: ['team token is invalid']
        )
      end
    end
  end

  describe '#add_user' do
    context 'with all documented fields' do
      let(:request) { {} }
      let(:expected_body) do
        {
          'token'    => 'team-token',
          'email'    => 'member@example.test',
          'name'     => 'Team Member',
          'password' => 'temporary password',
          'instant'  => 'true',
          'admin'    => 'true',
          'group'    => 'On-call'
        }
      end
      let(:response) do
        teams.add_user(
          email:    'member@example.test',
          name:     'Team Member',
          password: 'temporary password',
          instant:  true,
          admin:    true,
          group:    'On-call'
        )
      end

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/teams/add_user.json') do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump('status' => 1, 'request' => 'request-id'),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'posts to the add-user endpoint' do
        response

        expect(request.slice(:method, :path)).to eq(
          method: :post, path: '/1/teams/add_user.json'
        )
      end

      it 'serializes string-key JSON and literal true flag values' do
        response

        expect(Oj.strict_load(request[:body])).to eq(expected_body)
      end

      it 'uses the JSON content type' do
        response

        expect(request[:headers]).to include('Content-Type' => 'application/json')
      end

      it 'returns response metadata and headers' do
        expect(response).to have_attributes(
          status: 1, request: 'request-id', attributes: {}, headers: include('X-Request-Id' => 'header-id')
        )
      end
    end

    context 'with only an e-mail address' do
      let(:request) { {} }

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/teams/add_user.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
        end

        teams.add_user(email: 'member@example.test')
      end

      it 'omits optional fields' do
        expect(Oj.strict_load(request[:body])).to eq(
          'token' => 'team-token', 'email' => 'member@example.test'
        )
      end
    end

    context 'with blank text fields and disabled flags' do
      let(:request) { {} }
      let(:expected_body) do
        {
          'token'    => 'team-token',
          'email'    => 'member@example.test',
          'name'     => '',
          'password' => '',
          'group'    => ''
        }
      end

      before do
        captured_request = request
        Excon.stub(method: :post, path: '/1/teams/add_user.json') do |params|
          captured_request.replace(params)
          { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
        end

        teams.add_user(
          email: 'member@example.test', name: '', password: '', instant: false, admin: false, group: ''
        )
      end

      it 'preserves blank strings and omits false flags' do
        expect(Oj.strict_load(request[:body])).to eq(expected_body)
      end
    end

    context 'when Pushover rejects the request' do
      before do
        Excon.stub(
          { method: :post, path: '/1/teams/add_user.json' },
          {
            body:   Oj.dump('status' => 0, 'request' => 'request-id', 'errors' => ['user could not be added']),
            status: 400
          }
        )
      end

      it 'returns errors from the 400 response' do
        expect(teams.add_user(email: 'member@example.test')).to have_attributes(
          status: 0, request: 'request-id', errors: ['user could not be added']
        )
      end
    end

    [nil, '', '   ', 123].each do |invalid_email|
      it 'requires a nonblank e-mail string' do
        expect { teams.add_user(email: invalid_email) }
          .to raise_error ArgumentError, /email must be a nonblank String/
      end
    end

    %i[name password group].each do |field|
      it "requires #{field} to be a string when supplied" do
        expect { teams.add_user(email: 'member@example.test', field => 123) }
          .to raise_error ArgumentError, /#{field} must be a String/
      end
    end

    %i[instant admin].each do |field|
      it "requires #{field} to be boolean when supplied" do
        expect { teams.add_user(email: 'member@example.test', field => 'true') }
          .to raise_error ArgumentError, /#{field} must be true or false/
      end
    end

    it 'rejects unsupported fields' do
      expect { teams.add_user(email: 'member@example.test', role: 'owner') }
        .to raise_error ArgumentError, /unsupported team user parameter: role/
    end
  end

  shared_examples 'a team e-mail mutation' do |operation, path|
    let(:request) { {} }
    let(:response) { teams.public_send(operation, email: 'member@example.test') }
    let(:api_response) do
      {
        body:    Oj.dump('status' => 1, 'request' => 'request-id'),
        headers: { 'X-Request-Id' => 'header-id' },
        status:  200
      }
    end

    before do
      captured_request = request
      Excon.stub(method: :post, path: path) do |params|
        captured_request.replace(params)
        api_response
      end
    end

    it 'posts to the documented endpoint' do
      response

      expect(request.slice(:method, :path)).to eq(method: :post, path: path)
    end

    it 'serializes the team token and e-mail with string keys' do
      response

      expect(Oj.strict_load(request[:body])).to eq(
        'token' => 'team-token', 'email' => 'member@example.test'
      )
    end

    it 'uses the JSON content type' do
      response

      expect(request[:headers]).to include('Content-Type' => 'application/json')
    end

    it 'returns response metadata and headers' do
      expect(response).to have_attributes(
        status: 1, request: 'request-id', attributes: {}, headers: include('X-Request-Id' => 'header-id')
      )
    end

    context 'when Pushover rejects the request' do
      let(:api_response) do
        {
          body:   Oj.dump('status' => 0, 'request' => 'request-id', 'errors' => ['team operation failed']),
          status: 400
        }
      end

      it 'returns errors from the 400 response' do
        expect(response).to have_attributes(
          status: 0, request: 'request-id', errors: ['team operation failed']
        )
      end
    end

    [nil, '', '   ', 123].each do |invalid_email|
      it 'requires a nonblank e-mail string' do
        expect { teams.public_send(operation, email: invalid_email) }
          .to raise_error ArgumentError, /email must be a nonblank String/
      end
    end
  end

  describe '#revoke_invitation' do
    it_behaves_like 'a team e-mail mutation', :revoke_invitation, '/1/teams/revoke_invitation.json'
  end

  describe '#remove_user' do
    it_behaves_like 'a team e-mail mutation', :remove_user, '/1/teams/remove_user.json'
  end
end
