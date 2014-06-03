module GeneticAlgorithm
  #requires that the #size, #clone, #[], and #[]= methods are implemented
  module OnepointCrossover
    def cross other
      n = self.size
      raise ArgumentError, "size of other does not match size of self" if n != other.size
      
      a = self.clone
      b = other.clone
      point = rand(1...n)
      
      # swap
      a[0...point] = other[0...point]
      b[0...point] = self[0...point]
      
      return a,b
    end
  end
end
