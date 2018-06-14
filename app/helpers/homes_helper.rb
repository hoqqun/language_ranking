module HomesHelper

  def row_num(index)
    index + 1
  end

  def ratio(numer,denom)
    ((numer.to_f / denom.to_f) * 100).round(0)
  end

end
