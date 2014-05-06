module GeneticAlgorithm
  class Experiment
    def initialize algorithm
      @algorithm = algorithm
    end
    
    def run pop_size, n_generations
      population = Array.new(pop_size) {|i| Individual.new }
      population.sort!
      best_so_far = population.last
      fitness_history = { 0 => best_so_far.fitness }
  
      (1...n_generations).each do |n|
        population = @algorithm.evolve(population)
        
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
