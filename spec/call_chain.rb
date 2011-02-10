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