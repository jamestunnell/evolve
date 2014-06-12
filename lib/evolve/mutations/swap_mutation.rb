module Evolve
  # Requires that the #size and #[]= methods are implemented.
  module SwapMutation
    # swaps two values at random positions
    def mutate! pos
      pos2 = rand(0...self.size)
      self[pos], self[pos2] = self[pos2], self[pos]
    end
  end
end
