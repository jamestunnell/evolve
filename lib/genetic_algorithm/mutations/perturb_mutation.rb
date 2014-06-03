module GeneticAlgorithm
  # Requires that the #size, #bounds, and #[]= methods are implemented. If desired,
  # #beta can be implemented to override the default value.
  module PerturbMutation
    # replaces the chosen value by multiplying a uniform random value, between
    # -beta and +beta, by (upper bound - lower bound).
    def mutate! pos
      perc = rand(-self.beta..self.beta)
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
    
    def method_missing(mname)
      if mname == :beta
        return 0.1
      end
    end
  end
end
