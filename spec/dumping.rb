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
def check_body(body)
  dump(last_response.body, "#{CallChain::caller_file.split('/').last}_#{CallChain::caller_line}.htm") if last_response.body != body
  last_response.body.should include body
end

class CallChain
  def self.caller_file(depth=1)
    parse_caller(caller(depth+1).first)[0]
  end
  def self.caller_line(depth=1)
    parse_caller(caller(depth+1).first)[1]
  end
  def self.caller_method(depth=1)
    parse_caller(caller(depth+1).first)[2]
  end

  private

  #Stolen from ActionMailer, where this was used but was not made reusable
  def self.parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file   = Regexp.last_match[1]
      line   = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      [file, line, method]
    end
  end
end