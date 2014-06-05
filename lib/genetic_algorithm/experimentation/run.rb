require 'gnuplot'

module GeneticAlgorithm
  class Run
    attr_reader :best_individual, :best_fitnesses, :average_fitnesses
    
    def initialize best_individual, best_fitnesses, avg_fitnesses
      @best_individual = best_individual
      @best_fitnesses = best_fitnesses
      @average_fitnesses = avg_fitnesses
    end
    
    def last_generation
      [@best_fitnesses.keys.max,@average_fitnesses.keys.max].max
    end
    
    def best_fitness_dataset 
      Run.fitness_dataset average_fitnesses, "steps", "Best"
    end
    
    def average_fitness_dataset
      Run.fitness_dataset average_fitnesses, "lines", "Average"
    end
        
    def plot_best
      Plotter.fitness_plotter("Best").plot_dataset best_dataset
    end
    
    def plot_average
      Plotter.fitness_plotter("Average").plot_dataset average_dataset
    end
    
    def plot_all
      datasets = [ best_fitness_dataset, average_fitness_dataset ]
      Plotter.fitness_plotter("Best and Average").plot_datasets datasets
    end
    
    def average_fitness_at generation
      Run.fitness_at @average_fitnesses, generation
    end
    
    def best_fitness_at generation
      Run.fitness_at @best_fitnesses, generation
    end
    
    def self.fitness_dataset fitnesses, linestyle, linetitle
      x,y = fitnesses.to_a.transpose
      Gnuplot::DataSet.new( [x, y] ) do |ds|
        ds.with = linestyle
        ds.title = linetitle
      end
    end
    
    def self.fitness_at fitnesses, generation
      unless fitnesses.has_key?(generation)
        generation = fitnesses.keys.select {|n| n < generation }.max
      end
      fitnesses[generation]
    end
  end
end