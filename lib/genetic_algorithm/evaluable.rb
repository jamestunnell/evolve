module GeneticAlgorithm
  # requires @objective instance variable
  module Evaluable
    include Comparable
    
    def evaluate
      @objective.call(self)
    end
    
    def fitness
      if @fitness.nil?
        @fitness = self.evaluate
      end
      @fitness
    end
    
    def <=> other
      self.fitness <=> other.fitness
    end
  end
end
