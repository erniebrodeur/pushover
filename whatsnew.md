## unreleased
  * Fixed the save option to properly store the appkey and user key (@cptobvious for this).  As a result I added tests and cleaned up some internal code.

## 1.0.2
  * hotfixes
  * #13 added license to the gemspec
  * #15 fixed the configfile not being configurable on the cli (and testing now)
  * #16 fix for the --user option reading the app key (and tests).

## 1.0.1
  * hot fix (merge from @cptobvious) for optional notification parameters.

## 1.0.0
  * Sounds.
  * Emergency notifications.
  * Will properly trap 500 (server errors) being returned from the server.
  * Dropped the local sash in favor of the bini copy.

## 0.99.2:
  * Version constraint (thanks @freeatnet) on bini, I stupidily upgraded one without the other.

## 0.99.1:
  * Big one here, properly testing bin/pushover now.
  * Fixed a bug in the bin/pushover so --config_file and --app work as expected.
  * Empty params will no longer be sent to pushover.net
  * Fixed Pushover#notification, no longer overwrites params with it's arguments.
  * Added a user-agent to the POST's sent to pushover.net

## 0.99.0:
  * Added url and a url_title.
  * Added time, we can take an epoch or string.  The string is run through stdlib Time#parse, so effectively takes rfc822, html, xml, and a bunch of random bits.
  * Added gemnasium to the readme.
  * Added code climate to the readme.
  * Updated for Bini 0.6.0
  * Priority takes a text or integer argument now.

## 0.5.1:
  * SimpleCov and 100% test coverage
  * Webmock based testing for Pushover##notification.
  * Added integration to http://travis-ci.org

## 0.5.0:
  * Switched the order of App and it's derivatives so that it's name, api_key to make it more human readable.
   * Ditto for User.
  * Merged in me bones.
  * Using bini's logic whenever possible now instead of reinventing the wheel.

## 0.4.0:
  * Added priority and device specification.
  * Moved all the variables, including message, into the configure block.
  * Updated the gemspec with some more information.
  * Better output for error messages.

## 0.3.1
  * Added benwoody's changes back to the system, this allows for some nifty generators.
  * Fixed the nasty bug where it wasn't working once installed.

## 0.3.0
 * No longer need to supply credentials at all if you have some saved.
 * Fixed up a ton of documentation and spelling mistakes.
 * Various bug fixes.
 * About thirty percent of the tests are complete.
 * Added convenience methods for App.current_app and User.current_user to supply the correctly inherited credentials.
 * Will only create the save directory if you attempt to save.
 * You can specify config on the command line via --config_file
