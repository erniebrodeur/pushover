# Pushover

This gem provides a CLI and an API interface to http://pushover.net.

#### Build Status
<table border="0">
  <tr>
    <td>master</td>
    <td><a href=http://travis-ci.org/erniebrodeur/pushover?branch=master><img src="https://secure.travis-ci.org/erniebrodeur/pushover.png?branch=master"/></h> </td>
  </tr>
  <tr>
    <td>development</td>
    <td><a href=http://travis-ci.org/erniebrodeur/pushover?branch=development><img src="https://secure.travis-ci.org/erniebrodeur/pushover.png?branch=development"/></h> </td>
  </tr>
</table>

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

* Title: Title of your notifcation
* Config_file: the file to use for stored credentials.
* Priority: Priority of the message, as an integer (for now).
	* -1: low
	*  0: normal
	*	1: high
* Device: specific device to send the notification to.


#### Saving user and application.

You can also save and use stored information.  The username/application are titles.  They can be anything you want to reference them.

User:

		% pushover -u user_token --save-user email@somewhere.net

Application:

		% pushover -a app_key --save-app myApp

Delete coming soon.

Now, you can use these to send messages instead of having to remeber the key:

		% pushover -a myApp -u email@somewhere.net Hello from somewhere!

If you don't supply the application or user name, it will use the first one in the save file.

		% pushover so now I can just send an app.

Anytime you supply token's directly to the cli, it will ignore any saved information and try them.  This allows you to use it as a once-off tool while keeping credentials stored.

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
