module Evolve
  class Experiment
    NONE = :none
    MINIMAL = :minimal
    VERBOSE = :verbose
    UPDATE_DETAIL = [ NONE, MINIMAL, VERBOSE]
    
    attr_accessor :update_detail, :update_period
    def initialize algorithm
      @algorithm = algorithm
      @update_detail = NONE
      @update_period = 1
      
      yield self if block_given?
    end
    
    def self.avg_fitness population
      population.map {|x| x.fitness }.average
    end
    
    def run pop_size, seed_fn, stopping_fn
      population = Array.new(pop_size) {|i| seed_fn.call() }
      population.sort!
      best_so_far = population.last.clone
      avg_fitnesses = { 0 => Experiment.avg_fitness(population) }
      best_fitnesses = { 0 => best_so_far.fitness }
  
      case @update_detail
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
          best_so_far = best.clone
          best_fitnesses[n] = best.fitness
        end
        
        if (n % @update_period) == 0
          case @update_detail
          when VERBOSE
            puts "#{n}\t#{avg_fitness}\t#{best.fitness}\t#{best_so_far.fitness}"
          when MINIMAL
            print "."
          end
        end
        
        if block_given?
          yield n, population
        end
      end
      
      case @update_detail
      when VERBOSE, MINIMAL
        puts
      end
      
      return Run.new(best_so_far, best_fitnesses, avg_fitnesses)
    end
  end
end
