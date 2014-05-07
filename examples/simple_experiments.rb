require 'genetic_algorithm'
include GeneticAlgorithm
require 'pry'
class Individual < VectorPhenotype
  include UniformMutation
  include OnepointCrossover

  BOUNDS = [-512..512,-512..512]
  OBJECTIVE = ->(x){ -(x[0] - 2*x[1]) }
  
  def initialize entries=[]
    super(BOUNDS, OBJECTIVE, entries)
  end
  
  def clone
    self.class.new(entries)
  end
end

TOURNAMENT_SIZE = 6
SELECTION_PROBABILITY = 0.6
CROSSOVER_FRACTION = 0.8
MUTATION_RATE = 0.25

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

#begin
#  pop_size = 40
#  puts "Running experiment 1"
#  puts "population size = #{pop_size}"
#  run = experiment.run(pop_size,->(gen,best){ best.fitness >= 1536 })
#  puts "done"
#  
#  puts "stopping generation: #{run.best_generation}"
#  puts run.best_individual.inspect
#  
#  run.plot_fitness_history
#end
#
#puts ""

begin
  pop_size = 40
  n_runs = 256
  
  puts "Running experiment 2"
  puts "population size = #{pop_size}"
  puts "n_runs = #{n_runs}"
  
  runs = Array.new(n_runs) do |i|
    if i % 20 == 0
      puts "run #{i}"
    end
    experiment.run(pop_size,->(gen,best){ gen >= 1000 })
  end
  puts "done"
  
  runset = RunSet.new(runs)
  runset.plot_average_fitness
end

puts ""
#
#begin
#  n_runs = 256
#  
#  avg_best_generations = {}
#  
#  puts "Running experiment 3"
#  puts "n_runs = #{n_runs}"
#  
#  (10..200).step(10) do |pop_size|
#    puts "population size = #{pop_size}"
#      
#    runs = Array.new(n_runs) do |i|
#      if i % 20 == 0
#        puts "run #{i}"
#      end
#      experiment.run(pop_size,->(gen,best){ best.fitness >= 1536 })
#    end
#    runset = RunSet.new(runs)
#    best_generations = runset.best_fitnesses.transpose[0]
#    avg_best_gen = best_generations.inject(0,:+) / best_generations.size.to_f
#    avg_best_generations[pop_size] = avg_best_gen
#  end
#  puts "done"
#  
#  Gnuplot.open do |gp|
#    Gnuplot::Plot.new( gp ) do |plot|
#      plot.notitle
#      plot.xlabel "Population Size"
#      plot.ylabel "Average Stopping Generation"
#      
#      x,y = avg_best_generations.to_a.transpose
#      
#      plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
#        ds.with = "lines"
#        ds.notitle
#      end
#    end
#  end
#end