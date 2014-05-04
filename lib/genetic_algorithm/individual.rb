module GeneticAlgorithm
  module Individual
    def fitness
      if @fitness.nil?
        @fitness = self.evaluate
      end
      return @fitness
    end
  end
end
