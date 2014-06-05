module GeneticAlgorithm
  #requires that the #size, #clone, #[], and #[]= methods are implemented
  module OnepointCrossover
    def cross other
      n = self.size
      raise ArgumentError, "size of other does not match size of self" if n != other.size
      
      g = gamma
      raise ArgumentError, "" unless g.between?(0,1)
      m = (rand(0.0..gamma) * n).to_i
      
      a = self.clone
      b = other.clone
      point = rand(0...m) || 0
      
      # swap
      a[0...point] = other[0...point]
      b[0...point] = self[0...point]
      
      return a,b
    end
    
    def method_missing(mname)
      if mname == :gamma
        return 1.0
      end
    end
  end
end
