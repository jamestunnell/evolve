module GeneticAlgorithm
  class Fitness
    attr_reader :value
  end
  
  class FitnessTowardZero < Fitness
    def initialize value
      @value = value
    end
    
    def <=> other
      @value.abs < other.value.abs
    end
  end
  
  class FitnessTowardInfinity < Fitness
    def initialize value
      @value = value
    end
    
    def <=> other
      @value > other.value
    end
  end
  
  class FitnessTowardNegativeInfinity < Fitness
    def initialize value
      @value = value
    end
    
    def <=> other
      @value < other.value
    end
  end
end
