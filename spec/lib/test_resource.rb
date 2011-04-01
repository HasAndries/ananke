require 'lib/ananke/base'

class Test

  def get_basic
    'basic'
  end

  def post_basic
    'basic'
  end

  def post_params(q1, q2, f1, f2)
    'params' if q1 and q2 and f1 and f2
  end

  def error_generic
    Ananke::Base.error!
  end

  def error_501
    Ananke::Base.error! 501
  end

  def error_unhandled
    raise StandardError, 'Some Error'
  end

end
