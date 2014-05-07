module GeneticAlgorithm
  #requires that the #size, #clone, #[], and #[]= methods are implemented
  module OnepointCrossover
    def cross other
      raise ArgumentError, "size of other does not match size of self" if self.size != other.size
      
      a = self.clone
      b = other.clone
      point = rand(1...self.size)
      
      # swap
      a[0...point], b[0...point] = b[0...point], a[0...point]
      a[point...a.size], b[point...b.size] = b[point...b.size], a[point...a.size]
      
      return a,b
    end
  end
end
