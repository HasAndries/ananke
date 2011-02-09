require './spec/call_chain'
require 'fileutils'

def clear_dump
  dirname = File.join(File.dirname(__FILE__), "..", "dump")
  FileUtils::rm_rf(dirname)
  FileUtils::mkdir(dirname)
end
def dump(content, filename)
  File.open(File.expand_path(File.join(File.dirname(__FILE__), "..", "dump", "#{filename}")), 'w') {|f| f.write(content) }
end
def check_status(status)
  dump(last_response.body, "#{CallChain::caller_file.split('/').last}_#{CallChain::caller_line}.htm") if last_response.status != status
  last_response.status.should == status
end