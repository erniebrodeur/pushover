# Pushover [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/erniebrodeur/pushover) [![Build Status](https://travis-ci.org/erniebrodeur/pushover.png?branch=master)](https://travis-ci.org/erniebrodeur/pushover) [![Dependency Status](https://gemnasium.com/erniebrodeur/pushover.png)](https://gemnasium.com/erniebrodeur/pushover)

This gem provides a CLI and an API interface to http://pushover.net.

## Installation

To install:

		% gem install pushover

To use inside of an application, add this to the your gemfile:

		% gem 'pushover'

and run bundle to make it available:

		% bundle

## Usage

### API:
```ruby
require 'pushover'
```

To send with the very minimum amount of information.

```ruby
Pushover.notification('message', 'title', user:'USER_TOKEN', token:'APP_TOKEN')
```

Optional #configuration method:
```ruby
Pushover.configure do |config|
  config.user='USER_TOKEN'
  config.token='APP_TOKEN'
end

Pushover.notification('message', 'title')
```
### CLI:

To get help do, try ```--(h)elp```


		% pushover --h

To send a message.

		% pushover -u user_token -a app_key message is the rest of the cli.

#### Optional parameters

For the CLI:
* Config_file: The file to use for stored credentials.

For Pushover:
* Title:       Title of your notifcation
* Priority:    low, normal, high (or -1,0,1)
* Device:      Specific device to send the notification to.
* Time:        Epoch, or string.  See below.


#### Time
Time is tricky, I just pass the string off to the stdlib ```Time.parse```.  Therefore, if it fails I can't do much about it.  Though, it shouldn't fail, it seems to take just a ton of stuff.  You can always handle this yourself and just pass in an epoch (string or fixnum).

##### String examples
* rfc822: Tue, 14 Nov 2000 14:55:07 -0500
* xml: 1979-08-13T06:30:00.313UTC
* 'Aug 13, 1979 6:30'
* '1979/08/13, 6:30:50 UTC'

#### Saving

You can also save and use stored information.  The username/application are titles.  They can be anything you want to reference them.

User:

		% pushover -u user_token --save-user email@somewhere.net

Application:

		% pushover -a app_key --save-app myApp

Delete done in the api, not lifted to the cli.

Now, you can use these to send messages instead of having to remeber the key:

		% pushover -a myApp -u email@somewhere.net Hello from somewhere!

If you don't supply the application or user name, it will use the first one in the save file.

		% pushover so now I can just send an app.

Anytime you supply token's directly to the cli, it will ignore any saved information and try them.  This allows you to use it as a once-off tool while keeping credentials stored.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
