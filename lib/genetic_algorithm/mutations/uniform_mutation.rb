module GeneticAlgorithm
  # Requires that the #size, #bounds, and #[]= methods are implemented.
  module UniformMutation
    # replaces the chosen value with a uniform random value selected between the upper and lower bounds
    def mutate
      pos = rand(0...self.size)
      self[pos] = rand(self.bounds[pos])
    end
  end
end
