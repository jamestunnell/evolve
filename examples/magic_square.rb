require 'genetic_algorithm'
include GeneticAlgorithm
require 'pry'
class MagicSquare < Array
  include Evaluable
  include SwapMutation
  include SwapCrossover
  
  def gamma
    0.1
  end
  
  attr_reader :n, :m
  def initialize n, values=[]
    n2 = n*n
    @n = n
    @m = n*(n**2 + 1)/2 # magic constant (or magic sum)    
    
    unless values.any?
      values = (1..n2).to_a.shuffle
    end
    
    super(values)
  end
  
  def clone
    MagicSquare.new(@n, entries)
  end
  
  def evaluate
    deviations.sum
  end
  
  def <=> other
    -super(other)
  end
  
  def deviations
    n = @n
    m = @m
    
    rows = Array.new(n) do |i|
      row_start = n*i
      entries[row_start...(row_start + n)]
    end
    matrix = Matrix.rows(rows)
    
    row_sums = matrix.row_vectors.map{|y| y.inject(0,:+)}
    col_sums = matrix.column_vectors.map{|y| y.inject(0,:+)}
    l_diag_sum = Array.new(n){|i| matrix[i,i] }.inject(0,:+)
    r_diag_sum = Array.new(n){|i| matrix[i,n-i-1] }.inject(0,:+)
    sums = row_sums + col_sums + [l_diag_sum, r_diag_sum]
    sums.map {|sum| (sum-m).abs }
  end
end

CROSSOVER_FRACTION = 0.9
MUTATION_RATE = 0.02
POP_SIZE = 40
TOURNAMENT_SIZE = (0.1 * POP_SIZE).round
SELECTION_PROBABILITY = 0.6

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm) do |exp|
  exp.update_detail = Experiment::VERBOSE
  exp.update_period = 20
end

(3..5).each do |square_size|
  seed_fn = ->(){ MagicSquare.new(square_size) }
  stopping_fn = ->(gen,best){ best.fitness == 0 }
  
  run = experiment.run(POP_SIZE, seed_fn, stopping_fn)
  puts "took #{run.last_generation} generations"
  run.plot_all
end