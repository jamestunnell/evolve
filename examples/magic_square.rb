require 'genetic_algorithm'
include GeneticAlgorithm

class Individual < VectorPhenotype
  include SwapMutation
  include SwapCrossover
  
  OBJECTIVE = lambda do |x|
    n = x.n
    m = x.m
    
    rows = Array.new(n) do |i|
      row_start = n*i
      x[row_start...(row_start + n)]
    end
    matrix = Matrix.rows(rows)
    
    row_sums = matrix.row_vectors.map{|y| y.inject(0,:+)}
    col_sums = matrix.column_vectors.map{|y| y.inject(0,:+)}
    l_diag_sum = Array.new(n){|i| matrix[i,i] }.inject(0,:+)
    r_diag_sum = Array.new(n){|i| matrix[i,n-i-1] }.inject(0,:+)
    sums = row_sums + col_sums + [l_diag_sum, r_diag_sum]
    
    total = sums.inject(0,:+)
    ideal_total = sums.size * m
    max_deviation_total = sums.size * (m-n)
    deviation_total = (total-ideal_total).abs
    (max_deviation_total - deviation_total)/max_deviation_total.to_f
  end
  
  attr_reader :n, :m
  def initialize n, values=[]
    n2 = n*n
    @n = n
    @m = n*(n**2 + 1)/2 # magic constant (or magic sum)    
    bounds = [1..n2]*n2
    
    if values.any?
      if values.size != n2
        raise ArgumentError
      end
    else
      values = (1..n2).to_a.shuffle
    end
    
    super(bounds, OBJECTIVE, values)
  end
  
  def clone
    Individual.new(@n, entries)
  end
end

TOURNAMENT_SIZE = 10
SELECTION_PROBABILITY = 0.6
CROSSOVER_FRACTION = 0.75
MUTATION_RATE = 0.2
POP_SIZE = 50

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.notitle
    plot.xlabel "Square Size"
    plot.ylabel "Average Generations"
    
    n_runs = 16
    puts "n_runs = #{n_runs}\n"
  
    avg_gens = {}  
    stopping_fn = ->(gen,best){ best.fitness == 1 }

    (4..24).step(2) do |square_size|
      seed_fn = ->(){ Individual.new(square_size) }
      puts "  square size = #{square_size}"
      
      runs = Array.new(n_runs) do |i|
        run = experiment.run(POP_SIZE, seed_fn, stopping_fn)
      end
      runset = RunSet.new(runs)
      avg_gen = runset.average_generations
      puts "  avg gen = #{avg_gen}"
      avg_gens[square_size] = avg_gen
    end
    
    x,y = avg_gens.to_a.transpose
    plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
      ds.with = "lines"
      ds.notitle
    end
  end
end
