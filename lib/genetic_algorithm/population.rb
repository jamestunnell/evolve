module Enumerable
  def sorted?
    each_cons(2).all? { |a, b| (a <=> b) <= 0 }
  end
end

module GeneticAlgorithm
  class Population
    attr_reader :individuals
    
    def initialize pop_size, seeding_fn
      @individuals = Array.new(pop_size){|i| seeding_fn.call() }
    end
    
    def replace_worst new_individuals
      @individuals[0...new_individuals.size] = new_individuals
    end
    
    def sort!
      unless @individuals.sorted?
        @individuals.sort!
      end
    end
    
    def best
      
    end
  end
end
