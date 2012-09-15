# Pushover

This gem provides a CLI and an API interface to http://pushover.net

Currently it's a work in process and I haven't built out the CLI yet, that will happen shortly.

## Installation

To install:

		$ gem install pushover

To use inside of an application, add this to the your gemfile:

		$ gem 'pushover'

and run bundle to make it available:

		$ bundle

## Usage

### Progrmatic:

```ruby
require 'pushover'

Pushover.notification('your_token', 'app_token', 'message', 'title')
```

### CLI:

To send a message without any saved information.

		$ pushover -u user_token -a app_key message is the rest of the cli.

You can also save and use stored information.

User:

		$ pushover -u user_token --save-user username

Application:

		$ pushover -a app_key --save-user newapp

This will allow you to do:

		$ pushover -a new_app -u username message body.

Delete coming soon.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
