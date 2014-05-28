module GeneticAlgorithm
  # Requires that the #size, #bounds, and #[]= methods are implemented.
  module PerturbMutation
    # replaces the chosen value with a uniform random value selected between the upper and lower bounds
    def mutate pos
      perc = rand(-0.1..0.1)
      bound = self.bounds[pos]
      min,max = bound.first, bound.last
      newval = self[pos] + (max-min) * perc
      if newval < min
        self[pos] = min
      elsif newval > max
        self[pos] = max
      else
        self[pos] = newval
      end
    end
  end
end
