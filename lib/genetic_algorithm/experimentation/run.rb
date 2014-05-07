require 'gnuplot'

module GeneticAlgorithm
  class Run
    attr_reader :fitness_history, :best_individual
    
    def initialize fitness_history, best_individual
      @fitness_history = fitness_history
      @best_individual = best_individual
    end
    
    def plot_fitness_history
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
        
          plot.title  "Fitness History"
          plot.xlabel "Generation"
          plot.ylabel "Best Fitness (So Far)"
          
          x = fitness_history.keys
          y = x.map {|n| fitness_history[n] }
      
          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "steps"
            ds.notitle
          end
        end
      end
    end
    
    def generations
      @fitness_history.keys
    end
    
    def best_generation
      @fitness_history.select {|gen,fitness| fitness == @best_individual.fitness }.min[0]
    end
    
    def fitness_at generation
      unless @fitness_history.has_key?(generation)
        generation = generations.select {|n| n < generation }.max
      end
      @fitness_history[generation]
    end
  end
end