module GeneticAlgorithm
  class Experiment
    def initialize algorithm
      @algorithm = algorithm
    end
    
    def self.avg_fitness population
      fitnesses = population.map {|x| x.fitness }
      fitnesses.inject(0.0,:+) / fitnesses.size.to_f
    end
    
    def run pop_size, seed_fn, stopping_fn, print_progress: false
      population = Array.new(pop_size) {|i| seed_fn.call() }
      population.sort!
      best_so_far = population.last
      #avg_fitness_history = { 0 => Experiment.avg_fitness(population) }
      best_fitness_history = { 0 => best_so_far.fitness }
  
      if print_progress
        puts "gen\tavg\best\tbestsofar"
      end
      
      n = 0
      while !stopping_fn.call(n,best_so_far)
        population = @algorithm.evolve(population)
        n += 1
        
        avg_fitness = Experiment.avg_fitness(population)
        #avg_fitness_history[n] = avg_fitness 
        
        best = population.last
        if best > best_so_far
          best_so_far = best
          best_fitness_history[n] = best.fitness
        end
        
        if print_progress
          puts "#{n}\t#{avg_fitness}\t#{best.fitness}\t#{best_so_far.fitness}"
        end
      end
      best_fitness_history[n] = best_so_far.fitness
      
      return Run.new(n, best_fitness_history, best_so_far)
    end
  end
end
