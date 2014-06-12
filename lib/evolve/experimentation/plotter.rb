module Evolve
  class Plotter
    attr_accessor :title, :xlabel, :ylabel
    def initialize title: "", xlabel: "x", ylabel: "y" 
      @title = title
      @xlabel = xlabel
      @ylabel = ylabel
    end
    
    def plot_dataset dataset
      plot_datasets [dataset]
    end
    
    def plot_datasets datasets
      if datasets.empty?
        raise ArgumentError, "No datasets were given"
      end
      
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          plot.title @title
          plot.xlabel @xlabel
          plot.ylabel @ylabel
          plot.data += datasets
        end
      end
    end
    
    def self.fitness_plotter fitness_type
      Plotter.new(:title => "#{fitness_type} Fitness", :xlabel => "Generation", :ylabel => "Fitness")
    end
  end
end
