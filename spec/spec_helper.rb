require 'excon'
require 'pry'
require 'simplecov'
require 'simplecov-console'

Excon.defaults[:mock] = true

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  add_filter "/spec/"
end

require 'pushover'
