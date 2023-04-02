def p(*args)
  msgbox_p(*args)
end
  
def print(*args)
  msgbox(*args)
end

unless Array.method_defined?(:nitems)  
  class Array    
    def nitems      
      count{|x| !x.nil?}    
    end
    def to_s
      self.join('')
    end
  end
end

class String
  alias delete_utf8 delete
  def delete(arg)
    s = self.encode("UTF-16be", :invalid=>:replace, :replace=>"\uFFFD").encode('UTF-8')
    s.delete_utf8(arg + "\uFFFD")
  end
  
  alias delete_self_utf8 delete!
  def delete!(arg)
    self.encode!("UTF-16be", :invalid=>:replace, :replace=>"\uFFFD").encode!('UTF-8')
    delete_self_utf8(arg + "\uFFFD")
  end

  alias getchar []
  def [](*args)
    if args.size == 1 && args[0].is_a?(Fixnum)
      self.getbyte(args[0])
    else
      getchar(*args)
    end
  end
end

module Input
  DOWN = 2
  LEFT = 4
  RIGHT = 6
  UP = 8
  A = 11
  B = 12
  C = 13
  X = 14
  Y = 15
  Z = 16
  L = 17
  R = 18
  SHIFT = 21
  CTRL = 22
  ALT = 23
  F5 = 25
  F6 = 26
  F7 = 27
  F8 = 28
  F9 = 29
end