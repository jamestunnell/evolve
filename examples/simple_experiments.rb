require 'evolve'
include Evolve
require 'pry'

class Individual < Array
  include Evaluable
  include UniformMutation
  include OnepointCrossover

  BOUNDS = [-512..512,-512..512]
  
  attr_reader :bounds
  def initialize values=[]
    @bounds = BOUNDS
    unless values.any?
      values = @bounds.map {|bound| rand(bound) }
    end
    super(values)
  end
  
  def clone
    Individual.new(entries)
  end
  
  def evaluate
    (entries[0] - 2*entries[1]).abs
  end
  
  def <=>(other)
    -super(other)
  end
end

TOURNAMENT_SIZE = 6
SELECTION_PROBABILITY = 0.6
CROSSOVER_FRACTION = 0.9
MUTATION_RATE = 0.1

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

wait_for_optimal = ->(gen,best){ best.fitness == 0 }
new_individual = ->(){ Individual.new }

begin
  pop_size = 40
  puts "Running experiment 1"
  puts "population size = #{pop_size}"
  runs = Array.new(2) do |i|
    experiment.run(pop_size, new_individual, wait_for_optimal)
  end
  puts "done"
  
  puts "run #1 stopping generation: #{runs[0].last_generation}"
  puts "run #1 best individual: #{runs[0].best_individual.inspect}"
  puts "run #2 stopping generation: #{runs[1].last_generation}"
  puts "run #2 best individual: #{runs[1].best_individual.inspect}"
  
  RunSet.new(runs).plot_best
  RunSet.new(runs).plot_average
end

puts ""

begin
  pop_size = 40
  n_runs = 100
  
  puts "Running experiment 2"
  puts "population size = #{pop_size}"
  puts "n_runs = #{n_runs}"
  
  runs = Array.new(n_runs) do |i|
    if i % 20 == 0
      puts "run #{i}"
    end
    experiment.run(pop_size, new_individual, ->(gen,best){ gen >= 1000 })
  end
  puts "done"
  RunSet.new(runs).plot_average_best
end

puts ""

begin
  n_runs = 100
  
  avg_best_generations = {}
  
  puts "Running experiment 3"
  puts "n_runs = #{n_runs}"
  
  (10..200).step(10) do |pop_size|
    puts "population size = #{pop_size}"
      
    runs = Array.new(n_runs) do |i|
      if i % 20 == 0
        puts "run #{i}"
      end
      experiment.run(pop_size, new_individual, wait_for_optimal)
    end
    runset = RunSet.new(runs)
    avg_best_generations[pop_size] = runset.average_last_generation
  end
  puts "done"
  
  plotter = Plotter.new(xlabel: "Population Size", ylabel: "Stopping Generation (Average)")  
  x,y = avg_best_generations.to_a.transpose
  dataset = Gnuplot::DataSet.new( [x, y] ) do |ds|
    ds.with = "lines"
    ds.notitle
  end
  plotter.plot_dataset dataset
end