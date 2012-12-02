#!/usr/bin/ruby

guard :bundler do
	watch 'Gemfile'
	watch '*.gemspec'
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^bin/(.+)\.rb$})         { |m| "spec/bin/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { "spec" }
end

# guard :yard do
#   watch(%r{^lib/(.+)\.rb$})
# end
