#!/usr/bin/ruby
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
	watch 'Gemfile'
	watch 'theplatform-cli.gemspec'
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { "spec" }
end

# guard :yard do
#   watch(%r{^lib/(.+)\.rb$})
# end
