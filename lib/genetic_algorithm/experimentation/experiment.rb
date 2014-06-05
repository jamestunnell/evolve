module GeneticAlgorithm
  class Experiment
    NONE = :none
    MINIMAL = :minimal
    VERBOSE = :verbose
    PROGRESS_UPDATES = [ NONE, MINIMAL, VERBOSE]
    
    attr_accessor :progress_updates
    def initialize algorithm
      @algorithm = algorithm
      @progress_updates = NONE
    end
    
    def self.avg_fitness population
      population.map {|x| x.fitness }.average
    end
    
    def run pop_size, seed_fn, stopping_fn
      population = Array.new(pop_size) {|i| seed_fn.call() }
      population.sort!
      best_so_far = population.last
      avg_fitnesses = { 0 => Experiment.avg_fitness(population) }
      best_fitnesses = { 0 => best_so_far.fitness }
  
      case @progress_updates
      when VERBOSE
        puts "gen\tavg\tbest\tbestsofar"
      end
      
      n = 0
      while !stopping_fn.call(n,best_so_far)
        population = @algorithm.evolve(population)
        n += 1
        
        avg_fitness = Experiment.avg_fitness(population)
        avg_fitnesses[n] = avg_fitness
        
        best = population.last
        if best > best_so_far
          best_so_far = best
          best_fitnesses[n] = best.fitness
        end
        
        case @progress_updates
        when VERBOSE
          puts "#{n}\t#{avg_fitness}\t#{best.fitness}\t#{best_so_far.fitness}"
        when MINIMAL
          print "."
        end
      end
      
      case @progress_updates
      when VERBOSE, MINIMAL
        puts
      end
      
      return Run.new(best_so_far, best_fitnesses, avg_fitnesses)
    end
  end
end
