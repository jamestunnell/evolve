module GeneticAlgorithm
  # Requires that the #size and #[]= methods are implemented.
  module SwapMutation
    # swaps two values at random positions
    def mutate
      pos1 = rand(0...self.size)
      pos2 = rand(0...self.size)
      self[pos1], self[pos2] = self[pos2], self[pos1]
    end
  end
end
