# Pushover

This gem provides a CLI and an API interface to http://pushover.net

It's main usage as a CLI, see below for specifics.

Some CLI features:

  * Multiple users/applications can be stored.
  * Do not need to supply either, will find the first one available.
  * Supplying on the CLI will always override the stored variables.

## Installation

To install:

		$ gem install pushover

To use inside of an application, add this to the your gemfile:

		$ gem 'pushover'

and run bundle to make it available:

		$ bundle

## Usage

### API:

    require 'pushover'

To send with the very minimum amount of information.

    Pushover.notification('message', 'title', user:'USER_TOKEN', token:'APP_TOKEN')

Optional #configuration method:

		Pushover.configure do |config|
		  config.user='USER_TOKEN'
		  config.token='APP_TOKEN'
		end

		Pushover.notification('message', 'title')

### CLI:

To send a message.  This will override any saved information available.

		$ pushover -u user_token -a app_key message is the rest of the cli.

You can also save and use stored information.  The username/application are titles.  They can be anything you want to reference them.

User:

		$ pushover -u user_token --save-user username

Application:

		$ pushover -a app_key --save-user application

This will allow you to do:

		$ pushover -a new_app -u username message body.

If you don't supply any credentials, and it has them saved, it will use the first set saved.  This allows for a completely lazy mode ```pushover message body here``` for sending without having to constantly specify credentials.

Delete coming soon.

## Testing

CLI usage:

Testing, like this utility, it is a work in progress.  I'm in the process of lifting some of the code into another library (config, options), so I will likely not be making more tests for those pieces.

The app testing itself requires you to use your own credentials, that way you get the spam from pushover and not me.  I haven't figured out how to do this just yet.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
