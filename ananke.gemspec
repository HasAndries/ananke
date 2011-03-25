# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ananke}
  s.version = "1.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andries Coetzee"]
  s.date = %q{2011-03-24}
  s.description = %q{Full REST Implementation on top of Sinatra}
  s.email = %q{andriesc@mixtel.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["lib/ananke.rb", "lib/version.rb", "lib/ananke/settings.rb", "lib/ananke/linking.rb", "lib/ananke/routing.rb", "lib/ananke/validation.rb", "lib/ananke/helpers.rb", "lib/ananke/serialize.rb", "spec/dumping.rb", "spec/cov_adapter.rb", "spec/lib/ananke_spec.rb", "spec/lib/validation_spec.rb", "spec/lib/out_spec.rb", "spec/lib/json_spec.rb", "spec/lib/link_to_spec.rb", "spec/lib/route_for_spec.rb", "spec/lib/error_spec.rb", "spec/lib/linked_spec.rb", "spec/spec_helper.rb", "spec/call_chain.rb", "spec/nice_formatter.rb", "Gemfile", "Rakefile", "README.rdoc"]
  s.homepage = %q{https://github.com/HasAndries/ananke}
  s.post_install_message = %q{**************************************************

  Thank you for installing ananke-1.0.6

  Please be sure to look at README.rdoc to see what might have changed
  since the last release and how to use this GEM.

**************************************************
}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{ananke-1.0.6}
  s.test_files = ["spec/dumping.rb", "spec/cov_adapter.rb", "spec/lib/ananke_spec.rb", "spec/lib/validation_spec.rb", "spec/lib/out_spec.rb", "spec/lib/json_spec.rb", "spec/lib/link_to_spec.rb", "spec/lib/route_for_spec.rb", "spec/lib/error_spec.rb", "spec/lib/linked_spec.rb", "spec/spec_helper.rb", "spec/call_chain.rb", "spec/nice_formatter.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.1.2"])
      s.add_runtime_dependency(%q<colored>, ["~> 1.2"])
      s.add_runtime_dependency(%q<json>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5.6"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.3.9"])
    else
      s.add_dependency(%q<sinatra>, ["~> 1.1.2"])
      s.add_dependency(%q<colored>, ["~> 1.2"])
      s.add_dependency(%q<json>, ["~> 1.5.1"])
      s.add_dependency(%q<rack-test>, ["~> 0.5.6"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.3.9"])
    end
  else
    s.add_dependency(%q<sinatra>, ["~> 1.1.2"])
    s.add_dependency(%q<colored>, ["~> 1.2"])
    s.add_dependency(%q<json>, ["~> 1.5.1"])
    s.add_dependency(%q<rack-test>, ["~> 0.5.6"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.3.9"])
  end
end
