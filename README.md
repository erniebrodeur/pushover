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
