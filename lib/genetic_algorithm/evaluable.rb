module GeneticAlgorithm
  # requires that the #evaluate method be implemented.
  module Evaluable
    include Comparable
    
    def fitness
      if @fitness.nil?
        @fitness = self.evaluate
      end
      @fitness
    end
    
    def reevaluate
      @fitness = self.evaluate
    end
    
    def <=> other
      self.fitness <=> other.fitness
    end
  end
end
