require 'gnuplot'

module GeneticAlgorithm
  class Run
    attr_reader :n_generations, :fitness, :best_individual
    
    def initialize n_gen, fitness, best_individual
      @n_generations = n_gen
      @fitness = fitness
      @best_individual = best_individual
    end
    
    def plot_fitness
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
        
          plot.title  "Fitness History"
          plot.xlabel "Generation"
          plot.ylabel "Best Fitness (So Far)"
          
          x = fitness.keys
          y = x.map {|n| fitness[n] }
      
          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "steps"
            ds.notitle
          end
        end
      end
    end
    
    def generations
      @fitness.keys
    end
    
    def best_generation
      @fitness.select {|gen,fitness| fitness == @best_individual.fitness }.min[0]
    end
    
    def fitness_at generation
      unless @fitness.has_key?(generation)
        generation = generations.select {|n| n < generation }.max
      end
      @fitness[generation]
    end
  end
end