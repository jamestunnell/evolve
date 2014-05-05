module GeneticAlgorithm
  class Population
    attr_reader :individuals
    
    def initialize pop_size, seeding_fn
      @individuals = Array.new(pop_size){|i| seeding_fn.call() }
    end
    
    def replace_worst new_individuals
      @individuals[0...new_individuals.size] = new_individuals
    end
    
    def select n
    end
    
    # perform Stochastic Universal Sampling
    def select n_select
      f = total_fitness
      n = n_select
      p = f/n # distance between the pointers (F/N)
      start = rand(p)
      points = (0...n).each {|i| start + i*p}
      
      selected = []
      i = 0
      points.each do |point|
        while fitness of Population[i] < point
          i += 1
        selected.push(@individuals[i])
      return Keep
    end
      
    def total_fitness
      total = 0
      @individuals.each {|x| total += x}
      return total
    end
  end
end
