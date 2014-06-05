require 'gnuplot'

module GeneticAlgorithm
  class Run
    attr_reader :best_individual, :best, :average
    
    def initialize best_individual, best, avg
      @best_individual = best_individual
      @best = best
      @average = avg
    end
    
    def last_generation
      [@best.keys.max,@average.keys.max].max
    end
    
    def best_dataset 
      Run.fitness_dataset average, "steps", "Best"
    end
    
    def average_dataset
      Run.fitness_dataset average, "lines", "Average"
    end
        
    def plot_best
      Plotter.fitness_plotter("Best").plot_dataset best_dataset
    end
    
    def plot_average
      Plotter.fitness_plotter("Average").plot_dataset average_dataset
    end
    
    def plot_all
      datasets = [ best_dataset, average_dataset ]
      Plotter.fitness_plotter("Best and Average").plot_datasets datasets
    end
    
    def average_at generation
      Run.fitness_at @average, generation
    end
    
    def best_at generation
      Run.fitness_at @best, generation
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