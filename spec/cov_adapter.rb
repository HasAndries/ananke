require 'simplecov'

SimpleCov.adapters.define 'cov' do
  coverage_dir 'public/coverage'

  add_filter '/dump/'
  add_filter '/public/'
  add_filter '/spec/'
end