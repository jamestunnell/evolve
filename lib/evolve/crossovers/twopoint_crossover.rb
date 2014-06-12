module Evolve
  #requires that the #size, #clone, and #[] methods are implemented
  module TwopointCrossover
    def cross other
      n = self.size
      raise ArgumentError, "size of other does not match size of self" if n != other.size
      raise RuntimeError, "size must be greater than 2" if n <= 2
      
      g = gamma
      raise ArgumentError, "" unless g.between?(0,1)
      m = (rand(0.0..gamma) * n).to_i
      
      a = self.clone
      b = other.clone
      l_pos = rand(0...(n-m)) || 0
      r_pos = l_pos + m
      
      # swap
      a[l_pos...r_pos] = other[l_pos...r_pos]
      b[l_pos...r_pos] = self[l_pos...r_pos]
      
      return a,b
    end
    
    def method_missing(mname)
      if mname == :gamma
        return 1.0
      end
    end
  end
end
