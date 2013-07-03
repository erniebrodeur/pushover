#!/usr/bin/ruby
# Must be an array
test_cmd = [
  "bundle exec pushover a message"
]

guard :bundler do
	watch 'Gemfile'
	watch '*.gemspec'
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^bin/(.+)\.rb$})         { |m| "spec/bin/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { "spec" }
end

# guard :yard do
#   watch(%r{^lib/(.+)\.rb$})
# end

# guard :shell do
#   watch /.*/ do |m|
#     puts "Time: #{Time.now}, file saved: #{m}"
#     test_cmd.each do |cmd|

#       puts "=" * 80
#       puts "cmd: #{cmd}"
#       puts `#{cmd}`
#     end
#   end
# end
