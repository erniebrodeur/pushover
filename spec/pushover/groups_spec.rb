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

  describe '#get' do
    context 'with a valid group' do
      let(:request) { {} }
      let(:group_users) do
        [
          { 'user' => 'u' * 30, 'device' => nil, 'memo' => 'Jim', 'disabled' => false },
          {
            'user'     => 'v' * 30,
            'device'   => 'iphone',
            'memo'     => 'Mary',
            'disabled' => true,
            'name'     => 'Mary Example',
            'email'    => 'mary@example.test'
          }
        ]
      end
      let(:group_attributes) { { 'name' => 'On-call West', 'users' => group_users } }
      let(:response) { groups.get(group: group) }

      before do
        captured_request = request
        Excon.stub(
          method: :get,
          path:   "/1/groups/#{group}.json",
          query:  { token: 'app-token' },
          body:   nil
        ) do |params|
          captured_request.replace(params)
          {
            body:    Oj.dump({ 'status' => 1, 'request' => 'request-id' }.merge(group_attributes)),
            headers: { 'X-Request-Id' => 'header-id' },
            status:  200
          }
        end
      end

      it 'gets the group with the application token in the query string' do
        response

        expect(request.slice(:method, :path, :query)).to eq(
          method: :get, path: "/1/groups/#{group}.json", query: 'token=app-token'
        )
      end

      it 'does not send a request body' do
        response

        expect(request).not_to have_key(:body)
      end

      it 'returns response metadata' do
        expect(response).to have_attributes(status: 1, request: 'request-id')
      end

      it 'returns the group name and membership fields without reordering' do
        expect(response.attributes).to eq(group_attributes)
      end

      it 'preserves response headers' do
        expect(response.headers).to include('X-Request-Id' => 'header-id')
      end
    end

    context 'when the group has no users' do
      before do
        Excon.stub(
          { method: :get, path: "/1/groups/#{group}.json", query: { token: 'app-token' }, body: nil },
          {
            body:   Oj.dump('status' => 1, 'request' => 'request-id', 'name' => 'Empty Group', 'users' => []),
            status: 200
          }
        )
      end

      it 'returns an empty users array' do
        expect(groups.get(group: group).attributes).to eq('name' => 'Empty Group', 'users' => [])
      end
    end

    context 'when Pushover rejects the request' do
      let(:response) { groups.get(group: group) }

      before do
        Excon.stub(
          { method: :get, path: "/1/groups/#{group}.json", query: { token: 'app-token' }, body: nil },
          {
            body:   Oj.dump('status' => 0, 'request' => 'request-id', 'errors' => ['group is invalid']),
            status: 400
          }
        )
      end

      it 'returns errors from the 400 response' do
        expect(response).to have_attributes(status: 0, request: 'request-id', errors: ['group is invalid'])
      end
    end

    [nil, ''].each do |invalid_group|
      it 'requires a group key' do
        expect { groups.get(group: invalid_group) }.to raise_error ArgumentError, /group must be supplied/
      end
    end

    ['g' * 29, 'g' * 31, "#{'g' * 29}-", 123].each do |invalid_group|
      it 'requires exactly 30 alphanumeric characters' do
        expect { groups.get(group: invalid_group) }
          .to raise_error ArgumentError, /group must be 30 alphanumeric characters/
      end
    end
  end

  shared_examples 'a group mutation' do |operation, action, arguments, expected_body|
    let(:request) { {} }
    let(:response) { groups.public_send(operation, **arguments) }
    let(:api_response) do
      {
        body:    Oj.dump('status' => 1, 'request' => 'request-id'),
        headers: { 'X-Request-Id' => 'header-id' },
        status:  200
      }
    end

    before do
      captured_request = request
      Excon.stub(method: :post, path: "/1/groups/#{arguments[:group]}/#{action}.json") do |params|
        captured_request.replace(params)
        api_response
      end
    end

    it 'posts to the documented endpoint' do
      response

      expect(request.slice(:method, :path)).to eq(
        method: :post, path: "/1/groups/#{arguments[:group]}/#{action}.json"
      )
    end

    it 'serializes the documented string-key JSON body' do
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

    context 'when Pushover rejects the request' do
      let(:api_response) do
        {
          body:   Oj.dump('status' => 0, 'request' => 'request-id', 'errors' => ['group operation failed']),
          status: 400
        }
      end

      it 'returns errors from the 400 response' do
        expect(response).to have_attributes(
          status: 0, request: 'request-id', errors: ['group operation failed']
        )
      end
    end
  end

  describe '#add_user' do
    it_behaves_like(
      'a group mutation',
      :add_user,
      'add_user',
      { group: 'g' * 30, user: 'u' * 30, device: 'd' * 25, memo: 'é' * 200 },
      {
        'token'  => 'app-token',
        'user'   => 'u' * 30,
        'device' => 'd' * 25,
        'memo'   => 'é' * 200
      }
    )

    [
      [{ device: nil, memo: nil }, { 'token' => 'app-token', 'user' => 'u' * 30 }],
      [
        { device: '', memo: '' },
        { 'token' => 'app-token', 'user' => 'u' * 30, 'device' => '', 'memo' => '' }
      ]
    ].each do |optional_fields, expected_body|
      context "with #{optional_fields.values.compact.empty? ? 'nil' : 'blank'} optional fields" do
        let(:request) { {} }

        before do
          captured_request = request
          Excon.stub(method: :post, path: "/1/groups/#{group}/add_user.json") do |params|
            captured_request.replace(params)
            { body: Oj.dump('status' => 1, 'request' => 'request-id'), status: 200 }
          end
          groups.add_user(group: group, user: 'u' * 30, **optional_fields)
        end

        it 'distinguishes omitted fields from explicit blanks' do
          expect(Oj.strict_load(request[:body])).to eq(expected_body)
        end
      end
    end

    [nil, ''].each do |invalid_user|
      it 'requires a user key' do
        expect { groups.add_user(group: group, user: invalid_user) }
          .to raise_error ArgumentError, /user must be supplied/
      end
    end

    ['u' * 29, 'u' * 31, "#{'u' * 29}-", 123].each do |invalid_user|
      it 'requires a 30-character alphanumeric user key' do
        expect { groups.add_user(group: group, user: invalid_user) }
          .to raise_error ArgumentError, /user must be 30 alphanumeric characters/
      end
    end

    ['d' * 26, 'invalid device', 'phone,watch', 123].each do |invalid_device|
      it 'requires a blank or valid single device name' do
        expect { groups.add_user(group: group, user: 'u' * 30, device: invalid_device) }
          .to raise_error ArgumentError, /device must be blank or 1 to 25/
      end
    end

    it 'limits memos to 200 characters' do
      expect { groups.add_user(group: group, user: 'u' * 30, memo: 'é' * 201) }
        .to raise_error ArgumentError, /memo must be at most 200 characters/
    end

    it 'requires memos to be strings' do
      expect { groups.add_user(group: group, user: 'u' * 30, memo: 123) }
        .to raise_error ArgumentError, /memo must be a String/
    end

    it 'validates the group key before posting' do
      expect { groups.add_user(group: 'invalid', user: 'u' * 30) }
        .to raise_error ArgumentError, /group must be 30 alphanumeric characters/
    end
  end

  describe '#remove_user' do
    it_behaves_like(
      'a group mutation',
      :remove_user,
      'remove_user',
      { group: 'g' * 30, user: 'u' * 30 },
      { 'token' => 'app-token', 'user' => 'u' * 30 }
    )
  end

  describe '#disable_user' do
    it_behaves_like(
      'a group mutation',
      :disable_user,
      'disable_user',
      { group: 'g' * 30, user: 'u' * 30, device: 'phone_1' },
      { 'token' => 'app-token', 'user' => 'u' * 30, 'device' => 'phone_1' }
    )
  end

  describe '#enable_user' do
    it_behaves_like(
      'a group mutation',
      :enable_user,
      'enable_user',
      { group: 'g' * 30, user: 'u' * 30, device: '' },
      { 'token' => 'app-token', 'user' => 'u' * 30, 'device' => '' }
    )
  end

  describe '#rename' do
    it_behaves_like(
      'a group mutation',
      :rename,
      'rename',
      { group: 'g' * 30, name: 'Operations' },
      { 'token' => 'app-token', 'name' => 'Operations' }
    )

    [nil, ''].each do |invalid_name|
      it 'requires a group name' do
        expect { groups.rename(group: group, name: invalid_name) }
          .to raise_error ArgumentError, /name must be supplied/
      end
    end

    it 'requires the group name to be a string' do
      expect { groups.rename(group: group, name: 123) }
        .to raise_error ArgumentError, /name must be a String/
    end

    it 'validates the group key before posting' do
      expect { groups.rename(group: 'invalid', name: 'Operations') }
        .to raise_error ArgumentError, /group must be 30 alphanumeric characters/
    end
  end
end
