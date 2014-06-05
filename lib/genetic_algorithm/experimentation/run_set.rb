require 'gnuplot'

module GeneticAlgorithm
  class RunSet
    def initialize runs
      @runs = runs
    end
    
    def average_last_generation
      @runs.map {|run| run.last_generation }.average
    end
    
    def plot_best
      plotter = Plotter.fitness_plotter("Best")
      plotter.title += " #{@runs.size} runs"
      plotter.plot_datasets @runs.map {|run| run.best_dataset }
    end

    def plot_average
      plotter = Plotter.fitness_plotter("Average")
      plotter.title += " #{@runs.size} runs"
      plotter.plot_datasets @runs.map {|run| run.average_dataset }
    end
    
    def plot_average_best
      plotter = Plotter.fitness_plotter("(Average) Best")
      plotter.title += " #{@runs.size} runs"
      plotter.plot_dataset average_best_dataset
    end
    
    def plot_average_average
      plotter = Plotter.fitness_plotter("(Average) Average")
      plotter.title += " #{@runs.size} runs"
      plotter.plot_dataset average_average_dataset
    end

    def average_best
      RunSet.average_fitnesses @runs.map {|run| run.best }
    end
    
    def average_best_dataset
      Run.fitness_dataset average_best, "lines", "(Average) Best"
    end
    
    def average_average
      RunSet.average_fitnesses @runs.map {|run| run.average }
    end
    
    def average_average_dataset
      Run.fitness_dataset average_average, "lines", "(Average) Average"
    end
    
    def self.average_fitnesses fitness_histories
      max_gen = fitness_histories.map {|history| history.keys.max }.max
      Hash[
        (0..max_gen).map do |n|
          fitnesses = fitness_histories.map {|history| Run.fitness_at(history, n) }
          avg = fitnesses.average
          [n,avg]
        end
      ]
    end
  end
end
