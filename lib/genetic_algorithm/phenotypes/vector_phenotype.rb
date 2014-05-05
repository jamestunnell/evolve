module GeneticAlgorithm
  class VectorPhenotype < Array
    include Evaluable
    
    attr_reader :bounds
    def initialize bounds, objective, values = []
      @objective = objective
      @bounds = bounds
      
      if values.any?
        if values.size != bounds.size
          raise ArgumentError, "Number of values does not equal number of bounds"
        end
      else
        values = bounds.map {|range| rand(range)}
      end
      super(values)
    end
    
    def clone
      self.class.new(@bounds, @objective, entries)
    end
  end
end
