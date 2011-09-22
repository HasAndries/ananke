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
  system "gem push ananke-#{Ananke::VERSION}.gem"
end

task :doc do
  require 'rdoc/markup/to_html'
  h = RDoc::Markup::ToHtml.new
  content = File.open('README.rdoc', 'rb').read
  File.open('README.html', 'w'){|f|f.write(h.convert(content))}
  system "google-chrome README.html"
end

#Testing tasks
def make_task(name, path = 'spec')
  RSpec::Core::RakeTask.new(name) do |t|
    t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
    t.pattern = path.end_with?('.rb') ? path : "#{path}/**/*_spec.rb"
  end
end

make_task(:test)
make_task(:rest, 'spec/sinatra/rest_spec.rb')
make_task(:dsl,  'spec/sinatra/dsl_spec.rb')
make_task(:mime, 'spec/sinatra/mime_spec.rb.not_ready')

task :default => [:test]