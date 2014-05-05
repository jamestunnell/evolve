module GeneticAlgorithm
  # requires implementation of #evaluate method
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
