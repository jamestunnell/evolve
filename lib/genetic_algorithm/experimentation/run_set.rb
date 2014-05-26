require 'gnuplot'

module GeneticAlgorithm
  class RunSet
    def initialize runs
      @runs = runs
    end
    
    def plot_fitnesses
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          plot.title  "Fitness History (over #{@runs.size} runs)"
          plot.xlabel "Generation"
          plot.ylabel "Best Fitness (So Far)"
          
          @runs.each_index do |i|
            x = @runs[i].generations
            y = x.map {|n| @runs[i].fitness_at(n) }
            
            plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
              ds.with = "steps"
              ds.title = "Run #{i}"
            end
          end
          
        end
      end    
    end
    
    def average_generations
      @runs.map {|run| run.n_generations }.inject(0,:+) / @runs.size.to_f
    end
    
    def average_fitness
      max_gen = @runs.map {|run| run.generations.max }.max
      Hash[
        (0..max_gen).map do |n|
          fitnesses = @runs.map {|run| run.fitness_at(n) }
          avg = fitnesses.inject(0,:+) / @runs.size.to_f
           [n,avg]
        end
      ]
    end
    
    def best_fitnesses
      @runs.collect {|run| [run.best_generation, run.best_individual.fitness] }
    end
    
    def plot_average_fitness
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          plot.title  "Average Fitness (#{@runs.size} runs)"
          plot.xlabel "Generation"
          plot.ylabel "Average of Best Fitness (So Far)"
          
          x,y = average_fitness.to_a.transpose
          
          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "lines"
            ds.notitle
          end
        end
      end
    end
  end
end
