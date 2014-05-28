module GeneticAlgorithm
  # Maintains a constant population between generations. Performs selection,
  # crossover, and mutation. Preserves elite individuals if crossover_fraction
  # is < 1.
  class SimpleGA
    attr_reader :selector, :crossover_fraction, :mutation_rate
    
    def initialize selector, crossover_fraction, mutation_rate
      @selector = selector
      @crossover_fraction = crossover_fraction
      @mutation_rate = mutation_rate
    end
    
    def evolve population, steps = 1
      n_children = (@crossover_fraction * population.size).to_i
      
      population.sort!
      steps.times do |n|
        # breed children
        children = []
        while children.size < n_children
          mom, dad = @selector.select(population,2)
          child1, child2 = mom.cross(dad)
          children.push(child1)
          children.push(child2)
        end
        
        # for odd number of children
        if children.size > n_children
          children.pop
        end
        
        # fill in the bottom n_children slots with children, keeping the
        # upper slots unchanged (elitism)
        population[0...children.size] = children
        
        population.each do |individual|
          individual.mutate if rand < @mutation_rate
        end
        
        population.sort!
        if block_given?
          yield population
        end
      end
      
      unless block_given?
        return population
      end
    end
  end
end