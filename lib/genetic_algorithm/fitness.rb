module GeneticAlgorithm
  class Fitness
    attr_reader :value
  end
  
  class FitnessTowardZero < Fitness
    include Comparable
    
    def initialize value
      @value = value
    end
    
    def <=> other
      @value.abs <=> other.value.abs
    end
  end
  
  class FitnessTowardInfinity < Fitness
    include Comparable
    
    def initialize value
      @value = value
    end
    
    def <=> other
      @value <=> other.value
    end
  end
  
  class FitnessTowardNegativeInfinity < Fitness
    include Comparable
    
    def initialize value
      @value = value
    end
    
    def <=> other
      -(@value <=> other.value)
    end
  end
end
