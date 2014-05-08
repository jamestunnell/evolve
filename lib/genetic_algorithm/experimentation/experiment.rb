module GeneticAlgorithm
  class Experiment
    def initialize algorithm
      @algorithm = algorithm
    end
    
    def run pop_size, seed_fn, stopping_fn
      population = Array.new(pop_size) {|i| seed_fn.call() }
      population.sort!
      best_so_far = population.last
      fitness_history = { 0 => best_so_far.fitness }
  
      n = 0
      while !stopping_fn.call(n,best_so_far)
        population = @algorithm.evolve(population)
        n += 1
        
        best = population.last
        if best > best_so_far
          best_so_far = best
          fitness_history[n] = best.fitness
        end
      end
      
      return Run.new(fitness_history,best_so_far)
    end
  end
end
