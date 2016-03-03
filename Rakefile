require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "generate any non-existing spec files."
task :generate_spec_files do
	files = Dir.glob("exe/*")  + Dir.glob("lib/**/*.rb")
	spec_files = files.map {|f| f.gsub(".rb", "_spec.rb")}
	spec_files.each do |f|
		f = "spec/#{f}"
		if File.exist?(f) && File.stat(f).size > 0
			puts "	skip:     #{f}"
		else
			puts "	generate: #{f}"
			FileUtils.mkdir_p File.dirname(f)
			File.write(f, "require 'spec_helper'\n\n")
		end
	end
end


# Travis-ci.org
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
