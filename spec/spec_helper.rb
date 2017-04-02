require 'simplecov'
require 'simplecov-console'
require 'pry'
require 'excon'
Excon.defaults[:mock] = true

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  add_filter "/spec/"
end

require 'pushover'
