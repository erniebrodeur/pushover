unreleased:
  * Webmock based testing for Pushover#notification.
  * Added intergration to http://travis-ci.org

0.5.0:
  * Switched the order of App and it's derivatives so that it's name, api_key to make it more human readable.
   * Ditto for User.
  * Merged in me bones.
  * Using bini's logic whenever possible now instead of reinventing the wheel.
0.4.0:
	* Added priority and device specification.
	* Moved all the variables, including message, into the configure block.
  * Updated the gemspec with some more information.
  * Better output for error messages.
0.3.1
	* Added benwoody's changes back to the system, this allows for some nifty generators.
	* Fixed the nasty bug where it wasn't working once installed.
0.3.0
 * No longer need to supply credentials at all if you have some saved.
 * Fixed up a ton of documentation and spelling mistakes.
 * Various bug fixes.
 * About thirty percent of the tests are complete.
 * Added convenience methods for App.current_app and User.current_user to supply the correctly inherited credentials.
 * Will only create the save directory if you attempt to save.
 * You can specify config on the command line via --config_file
