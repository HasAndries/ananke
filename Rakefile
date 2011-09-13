require 'rubygems'
require "rake"
require "rspec/core/rake_task"

#Building Gem and publishing
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "sinatra/version"
task :build do
  system "gem build ananke.gemspec"
end

task :release => :build do
  system "gem push ananke-#{Ananke::VERSION}"
end

#Testing tasks
def make_task(name, html = false, path = 'spec')
  options = ["-c", "-r ./spec/spec_helper.rb"]
  options << "-f progress" if !html
  options << "-o results/test_results.htm" if html
  pattern = path.end_with?('.rb') ? path : "#{path}/**/*_spec.rb"

  RSpec::Core::RakeTask.new(name) do |t|
    t.rspec_opts = options
    t.pattern = pattern
  end
end

make_task(:test)
make_task(:rest,        false,  'spec/sinatra/rest_spec.rb')
make_task(:dsl,         false,  'spec/sinatra/dsl_spec.rb')
make_task(:mime,        false,  'spec/sinatra/mime_spec.rb.not_ready')
make_task(:doc,         true)

task :default => [:test]