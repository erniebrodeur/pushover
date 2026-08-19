# Pushover

This gem provides a CLI and a Ruby API for [Pushover](https://pushover.net).

## Installation

Install the gem:

```shell
gem install pushover
```

Or add it to your Gemfile and run `bundle install`:

```ruby
gem 'pushover'
```

## Ruby API

Create one client with your application token, then use its API resources:

```ruby
require 'pushover'

client = Pushover::Client.new(token: 'app-token')

response = client.messages.create(
  user: 'user-or-group-key',
  message: 'Deployment completed',
  title: 'Production'
)
```

`messages.create` supports the Pushover Message API's JSON parameters:

- `user` and `message` are required.
- `device`, `title`, `url`, `url_title`, `priority`, `sound`, `timestamp`, and `ttl` are optional.
- `html` and `monospace` accept booleans or `1` and `0`, but cannot both be enabled.
- Emergency priority (`priority: 2`) requires `retry` and `expire`, and may include `callback` and `tags`.
- Attachments use `attachment_base64` with `attachment_type`, such as `image/png`, and are limited to 5 MiB after decoding.

To encrypt the supported message fields end to end, pass the 64-character hexadecimal key configured on the receiving devices:

```ruby
response = client.messages.create(
  user: 'user-or-group-key',
  message: 'Encrypted message',
  encryption_key: ENV.fetch('PUSHOVER_ENCRYPTION_KEY')
)
```

Deterministic request errors raise `ArgumentError` before a network request. Pushover API errors, including HTTP 4xx responses, are returned as `Pushover::Response` objects:

```ruby
response.status     # 0 or 1
response.request    # Pushover request identifier
response.errors     # API validation errors, if any
response.receipt    # emergency message receipt, if any
response.headers    # response headers, including application limits
response.attributes # other response fields
```

Retrieve the status of an emergency message receipt through the same client:

```ruby
response = client.receipts.get(receipt: 'AbCdEf0123456789GhIjKlMnOpQrSt')
```

Cancel future retries for an emergency message before it expires:

```ruby
response = client.receipts.cancel(receipt: 'AbCdEf0123456789GhIjKlMnOpQrSt')
```

Cancel future retries for all active emergency messages sent by the application with one tag:

```ruby
response = client.receipts.cancel_by_tag(tag: 'l=chicago')
```

Receipt identifiers must contain exactly 30 alphanumeric characters. Receipt status fields are returned in `response.attributes`, including `acknowledged`, `acknowledged_at`, `acknowledged_by`, `acknowledged_by_device`, `last_delivered_at`, `expired`, `expires_at`, `called_back`, and `called_back_at`.

Cancellation stops future emergency-priority retries. `cancel_by_tag` accepts one nonempty tag and encodes it as a single URL path segment. Pushover permits receipt polling no more often than once every five seconds and retains receipt status for up to one week. The client does not enforce that interval or automatically retry requests. Connection failures continue to raise Excon transport exceptions.

Validate a user or group identifier, optionally for one device:

```ruby
response = client.users.validate(
  user: 'uQiRzpo4DXghDmr9QzzfQu27cmVRsG',
  device: 'droid2'
)
```

`user` must be a 30-character alphanumeric user or group identifier. `device` is optional and, when supplied, must be 1 to 25 characters using letters, numbers, underscores, or hyphens. Without a device, Pushover validates that the account has at least one active device. Successful validation returns active device names in `response.attributes['devices']` and licensed platforms in `response.attributes['licenses']`. Invalid or inactive users and devices are returned as Pushover API errors in the response.

Retrieve the sounds available to the application account:

```ruby
response = client.sounds.get
available_sounds = response.attributes['sounds']
```

The sounds hash maps each value accepted by `messages.create(sound: ...)` to its display name. It includes Pushover's built-in sounds and custom sounds uploaded by the account that owns the application token. Omit `sound`, or pass a blank value, to use the recipient's default sound.

Retrieve the current monthly message usage limits:

```ruby
response = client.limits.get
monthly_limit = response.attributes['limit']
remaining = response.attributes['remaining']
reset_at = Time.at(response.attributes['reset'])
```

`limit` is the account or team's monthly allowance, including purchased capacity. `remaining` is the number of messages left, and `reset` is the Unix timestamp for the next reset. Despite the historical endpoint and header names, these values represent usage shared across all applications owned by the account or team.

Update one or more fields on a user's registered Glances widgets:

```ruby
response = client.glances.update(
  user: 'uQiRzpo4DXghDmr9QzzfQu27cmVRsG',
  title: 'Widgets Sold',
  text: '30',
  percent: 75
)
```

`title`, `text`, and `subtext` accept up to 100 characters. `count` accepts any integer, including negative values, and `percent` accepts integers from 0 through 100. `device` may restrict the update to one device. At least one data field is required. Omitted data fields retain their previous values; pass an empty string to clear a field, including `count` or `percent`.

Glances updates do not create notifications and may take up to 10 minutes to appear. Pushover recommends at least 20 minutes between Apple Watch updates, and watchOS limits them to 50 per day. The client does not throttle updates.

Create an empty delivery group:

```ruby
response = client.groups.create(name: 'On-call West')
group_key = response.attributes['group']
```

The application token may belong to any application on the account or team that will own the group. Group names must be unique within that account; Pushover validates uniqueness. The returned 30-character group key can be used as the `user` value when sending messages.

List the delivery groups owned by the application token's account or team:

```ruby
response = client.groups.list
group_entries = response.attributes['groups']
```

Each entry contains a `group` key and `name`. Pushover does not document a sort order or pagination contract, so callers should not depend on response ordering.

Retrieve a delivery group's name and memberships:

```ruby
response = client.groups.get(group: group_key)
group_name = response.attributes['name']
members = response.attributes['users']
```

Each member contains `user`, `device`, `memo`, and `disabled`. A `device` of `nil` represents an unrestricted membership. Team members also include `name` and `email`. Pushover does not document membership ordering or pagination.

Manage group memberships and names:

```ruby
client.groups.add_user(group: group_key, user: user_key, device: 'iphone', memo: 'Primary on-call')
client.groups.disable_user(group: group_key, user: user_key, device: 'iphone')
client.groups.enable_user(group: group_key, user: user_key, device: 'iphone')
client.groups.remove_user(group: group_key, user: user_key, device: 'iphone')
client.groups.rename(group: group_key, name: 'Operations')
```

An added membership may include one device and a memo of up to 200 characters. Omitting `device`, or passing it as blank, creates an all-device membership. For removal, disabling, and enabling, an omitted or blank device affects every membership matching the user key; pass a device to target only that membership. Pushover enforces group-name uniqueness on the owning account or team.

Optionally migrate an existing user key to an application subscription:

```ruby
response = client.subscriptions.migrate(
  subscription: 'Forum-f504h08fhlasdfj',
  user: 'uQiRzpo4DXghDmr9QzzfQu27cmVRsG',
  device_name: 'droid2',
  sound: 'pushover'
)
subscribed_user_key = response.attributes['subscribed_user_key']
```

Pushover calls this user-key migration, but it is only needed when voluntarily adopting subscription-managed recipients for previously collected user keys. `subscription` must be a nonempty subscription code, and `user` must be a 30-character alphanumeric user key. `device_name` is optional and follows the standard device-name rules. `sound` may be any string because Pushover supports account-specific custom sounds; a blank sound selects the user's default. Pushover validates live subscriptions, users, devices, and sound availability.

Retrieve the application's available prepaid license credits, or permanently assign one credit:

```ruby
credits = client.licenses.get.attributes['credits']

response = client.licenses.assign(
  email: 'person@example.com',
  os: 'Desktop'
)
remaining_credits = response.attributes['credits']
```

`licenses.assign` requires a valid 30-character `user` key or a nonblank `email`; the gem does not invent an e-mail format beyond that documented requirement. `os` may be blank, `Android`, `iOS`, or `Desktop`. A blank or omitted value assigns the license to the first platform the user registers. Each call assigns one permanent, nonrefundable license. Assignment failures remain structured in `response.errors`, and the client never automatically retries the assignment.

### Legacy API compatibility

The former message and receipt interfaces remain available as deprecated compatibility wrappers, with no scheduled removal:

```ruby
Pushover::Message.new(token: 'app-token', user: 'user-key', message: 'Hello').push
Pushover::Receipt.new(token: 'app-token', receipt: 'AbCdEf0123456789GhIjKlMnOpQrSt').get
```

Calling `push` or `get` emits a deprecation warning naming the replacement and delegates to the shared client resources. New code should use `client.messages.create` and `client.receipts.get`. The legacy raw `attachment` keyword remains accepted for constructor compatibility, but non-nil values are rejected because they cannot be safely translated to the supported `attachment_base64` and `attachment_type` interface.

## CLI

Send a message:

```shell
pushover --token=app-token --user=user-key message here we go again
pushover -tapp-token -uuser-key message here we go again
```

Get receipt details:

```shell
pushover -tapp-token receipt AbCdEf0123456789GhIjKlMnOpQrSt
```

## Contributing

1. Fork the repository.
2. Switch to `development`.
3. Create a feature branch.
4. Commit and push your changes.
5. Open a pull request against `development`.
