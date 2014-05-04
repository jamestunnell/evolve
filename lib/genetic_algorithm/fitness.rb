module GeneticAlgorithm
  class Fitness
    def initialize value, bigger_is_better
      @value = value
      @bigger_is_better = bigger_is_better
    end
    
    def <=> other
      if @bigger_is_better
        @value <=> other.value
      else
        -(@value <=> other.value)
      end
    end
    
    def self.bigger_is_better value
      Fitness.new(value, true)
    end
    
    def self.smaller_is_better value
      Fitness.new(value, false)
    end
  end
end
