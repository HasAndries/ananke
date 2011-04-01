
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

end
