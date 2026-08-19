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

Receipt identifiers must contain exactly 30 alphanumeric characters. Receipt status fields are returned in `response.attributes`, including `acknowledged`, `acknowledged_at`, `acknowledged_by`, `acknowledged_by_device`, `last_delivered_at`, `expired`, `expires_at`, `called_back`, and `called_back_at`.

Cancellation stops future emergency-priority retries. Pushover permits receipt polling no more often than once every five seconds and retains receipt status for up to one week. The client does not enforce that interval or automatically retry requests. Connection failures continue to raise Excon transport exceptions.

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
