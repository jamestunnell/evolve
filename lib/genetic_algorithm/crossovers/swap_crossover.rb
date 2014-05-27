module GeneticAlgorithm
  #requires that the #size, #clone, #index, #[], and #[]= methods are implemented
  module SwapCrossover
    def cross other
      raise ArgumentError, "size of other does not match size of self" if self.size != other.size
      
      a = self.clone
      b = other.clone
      
      n_swaps = rand(1...self.size)
      n_swaps.times do |i|
        pos = rand(1...self.size)
        a1 = a[pos]
        b1 = b[pos]
        a2i = a.index(b1)
        b2i = b.index(a1)
        
        if a2i and b2i
          a[pos], a[a2i] = b1, a1
          b[pos], b[b2i] = a1, b1
        end
      end
      
      return a,b
    end
  end
end
