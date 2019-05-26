# Pushover
[![Build Status](https://travis-ci.org/erniebrodeur/pushover.svg?branch=master)](https://travis-ci.org/erniebrodeur/pushover) [![codecov](https://codecov.io/gh/erniebrodeur/pushover/branch/master/graph/badge.svg)](https://codecov.io/gh/erniebrodeur/pushover)

This gem provides a CLI and an API interface to https://pushover.net.

## Installation

To install:

    gem install pushover

To use inside of an application, add this to the your gemfile:

    gem 'pushover'

and run bundle to make it available:

    bundle


## Usage

For now, not much is supported on the CLI.

Sending a message:

    pushover --token=your_app_token --user=user_key message here we go again, on my own.
    pushover -tyour_app_token -uuser_key message here we go again, on my own.

Getting receipt details:


    pushover -tyour_app_token receipt receipt-hash

Currently unsupported message features:
 - attachments
 - callbacks
 - setting timestamp


### Api

``` ruby
  require 'pushover'

  ### message
  message = Pushover::Message.new(token: 'token', user: 'user_key', message: '...')
  message.push


  ### Receipt
  Pushover::Message.new(token: 'token', user: 'user_key', message: '...', 'priority': 2, expire: 1, retry: 60).push

  receipt = Pushover::Receipt.new(receipt: "receipt", token: 'token')
  receipt.get

  ### Responses
  response = Pushover::Message.new(token: 'token', user: 'user_key', message: '...').push

  # the below data is populated from the response
  puts response.status     # return the status of the request, 0 or 1
  puts response.request    # uuid of the request
  puts response.errors     # array of errors (if any)
  puts response.receipt    # receipt (if requested)
  puts response.headers    # response headers (includes limits)
  puts response.attributes # any other k/v pair returned from pushover
```

## Contributing

1. Fork it
2. Switch to development (`git checkout development`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request against `development`
