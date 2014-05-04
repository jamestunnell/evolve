module GeneticAlgorithm
  class Fitness
    include Comparable
    
    attr_reader :value
    def initialize value
      @value = value
    end
  end
  
  class FitnessTowardZero < Fitness
    def <=> other
      @value.abs < other.value.abs
    end
  end
  
  class FitnessTowardInfinity < Fitness
    def <=> other
      @value > other.value
    end
  end
  
  class FitnessTowardNegativeInfinity < Fitness
    def <=> other
      @value < other.value
    end
  end
end
