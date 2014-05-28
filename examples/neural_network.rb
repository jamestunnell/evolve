require 'genetic_algorithm'
require 'matrix'
require 'narray'

require 'pry'

include GeneticAlgorithm

# Character recognition using a neural network, where
# NN weights are trained using a genetic algorithm.

def signum x
  x > 0 ? 1 : 0
end

class MLP < Array
  attr_reader :n_in, :n_hidden, :n_out
  def initialize n_in, n_hidden, n_out
    values = Array.new((n_in+1) * n_hidden + (n_hidden+1) * n_out){rand-0.5}
    @n_in = n_in
    @n_hidden = n_hidden
    @n_out = n_out
    super(values)
  end
    
  def forward inputs
    unless inputs.size == @n_in
      raise ArgumentError, "Input size is #{inputs.size}, but should be #{@n_in}"
    end
    
    n_in_weights = (@n_in + 1) * @n_hidden
    in_weights = slice(0...n_in_weights).each_slice(@n_hidden).to_a
    hidden_weights = slice(n_in_weights..-1).each_slice(@n_out).to_a
    
    inputs.unshift(-1)
    hidden_outputs = (Matrix.row_vector(inputs) * Matrix.rows(in_weights)).map {|x| signum(x) }
    hidden_outputs = hidden_outputs.to_a.flatten
    hidden_outputs.unshift(-1)
    outputs = (Matrix.row_vector(hidden_outputs) * Matrix.rows(hidden_weights)).map {|x| signum(x) }
    outputs.to_a.flatten
  end  
end
  
class CharRecognizer < MLP
  include Evaluable
  include UniformMutation
  include SwapCrossover
  
  CHARCODES = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3,
    "E" => 4
  }
  
  CHARBITS = {
    "A" => [0,1,1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1],
    "B" => [1,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,1,1,1,1,0],
    "C" => [0,1,1,1,0,1,0,0,0,1,1,0,0,0,0,1,0,0,0,1,0,1,1,1,0],
    "D" => [1,1,1,1,0,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0],
    "E" => [1,1,1,1,1,1,0,0,0,0,1,1,1,0,0,1,0,0,0,0,1,1,1,1,1]
  }
  
  N_INPUTS = 25
  N_OUTPUTS = Math.log2(CHARCODES.size).ceil
  
  attr_reader :bounds
  def initialize n_hidden
    super(N_INPUTS,n_hidden,N_OUTPUTS)
    @bounds = [(-10.0)..(10.0)] * self.size
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def evaluate
    recognized = CHARBITS.select do |char,bits|
      recognize(bits) == CHARCODES[char]
    end
    recognized.size
  end
  
  def recognize in_bits
    out_bits = self.forward(in_bits.clone)
    out_bits.inject(0){|r,i| r << 1 | i} # convert array of bits to integer
  end
end

TOURNAMENT_SIZE = 10
SELECTION_PROBABILITY = 0.5
CROSSOVER_FRACTION = 0.8
MUTATION_RATE = 0.25
POP_SIZE = 50

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

N_HIDDEN = 52
seed_fn = ->(){ CharRecognizer.new(N_HIDDEN) }
stop_fn = ->(gen,best){ best.fitness > 2 }
run = experiment.run(POP_SIZE,seed_fn,stop_fn)
run.plot_fitness
#population = Array.new(POP_SIZE) {|i| seed_fn.call() }
binding.pry
