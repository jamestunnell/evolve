module GeneticAlgorithm
  module Algorithms
    # Maintains a constant population between generations.
    # Performs selection, breeding, and mutation.
    class SimpleGA
      def initialize selector, crossover_fraction, mutation_rate
        @selector = selector
        @crossover_fraction = crossover_fraction
        @mutation_rate = mutation_rate
      end
      
      def evolve population
        population.sort
        children = self.breed(population)
        elite = population.pop(population.size - n_children)
        return children + elite
      end
      
      def breed population
        n_children = @crossover_fraction * population.size
        children = []
        while children.size < n_children
          mom, dad = @selector.select(population,2)
          child1, child2 = mom.cross(dad)
          child1.mutate if rand < @mutation_rate
          child2.mutate if rand < @mutation_rate
          children.push(child1)
          children.push(child2)
        end
        
        if children.size > n_children
          children.pop
        end
        return children
      end
    end
  end
end