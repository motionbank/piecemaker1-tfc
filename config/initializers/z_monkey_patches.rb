class NilClass
  def to_time_string
    'warning no video!'
  end
end

class Fixnum
  def self.zero_pad(num)
    num < 10 ? '0' + num.to_s : num.to_s
  end
  def to_time_string
    timestring = ''
    hourmin = self.to_i.divmod(3600)
    minsec = hourmin[1].divmod(60)
    timestring << Fixnum.zero_pad(hourmin[0])+'h' if hourmin[0] > 0
    timestring << Fixnum.zero_pad(minsec[0])+'m'
    timestring << Fixnum.zero_pad(minsec[1])+'s'
  end
end
class Float
  def to_time_string
    self.to_i.to_time_string
  end
end

