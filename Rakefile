require 'rubygems'
require "rake"
require "rake/rdoctask"
require 'rake/gempackagetask'
require "rspec/core/rake_task"
require "./lib/sinatra/ananke"
require "./lib/sinatra/version"

require File.expand_path("../lib/sinatra/version", __FILE__)
gemspec = Gem::Specification.new do |gem|
  gem.name        = "sinatra-rest"
  gem.version     = Ananke::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Andries Coetzee"]
  gem.email       = "andriesc@mixtel.com"
  gem.summary     = "#{gem.name}-#{Ananke::VERSION}"
  gem.description = "Full REST Implementation on top of Sinatra"
  gem.homepage    = "https://github.com/HasAndries/MiXREST"

  gem.rubygems_version   = "1.5.0"

  gem.files            = FileList['lib/**/*', 'spec/**/*', 'Gemfile', 'Rakefile', 'README.rdoc']
  gem.test_files       = FileList['spec/**/*']
  gem.extra_rdoc_files = [ "README.rdoc" ]
  gem.rdoc_options     = ["--charset=UTF-8"]
  gem.require_path     = "lib"

  gem.post_install_message = %Q{**************************************************

  Thank you for installing #{gem.summary}

  Please be sure to look at README.rdoc to see what might have changed
  since the last release and how to use this GEM.

**************************************************
}
  gem.add_dependency              "colored",   "~> 1.2"
  gem.add_dependency              "json",      "~> 1.5.1"
  gem.add_dependency              "sinatra",   "~> 1.2.1"

  gem.add_development_dependency  "rack-test", "~> 0.5.7"
  gem.add_development_dependency  "rake",      "~> 0.8.7"
  gem.add_development_dependency  "rspec",     "~> 2.5.0"
  gem.add_development_dependency  "simplecov", "~> 0.4.2"
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

desc %{Build the gemspec file.}
task :gemspec do
  gemspec.validate
  File.open("#{gemspec.name}.gemspec", 'w'){|f| f.write gemspec.to_ruby }
end

#===========================RAKE TASKS=========================
def make_task(name, docs = false, path = 'spec')
  options = ["-c", "-r ./spec/spec_helper.rb"]
  options << "-f progress" if !docs
  options << "-f NiceFormatter" << "-o results/test_results.htm" << "-r ./spec/nice_formatter.rb" if docs
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