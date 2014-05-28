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

class MLP
  attr_reader :in_weights, :hidden_weights
  def initialize n_in, n_hidden, n_out
    @in_weights = Array.new(n_in+1){ Array.new(n_hidden){ rand-0.5 }}
    @hidden_weights = Array.new(n_hidden+1){ Array.new(n_out){ rand-0.5 }}
    @n_in = n_in
    @n_hidden = n_hidden
    @n_out = n_out
  end
    
  def forward inputs
    unless inputs.size == @n_in
      raise ArgumentError, "Input size is #{inputs.size}, but should be #{@n_in}"
    end
    
    inputs.unshift(-1)
    hidden_outputs = (Matrix.row_vector(inputs) * Matrix.rows(@in_weights)).map {|x| signum(x) }
    hidden_outputs = hidden_outputs.to_a.flatten
    hidden_outputs.unshift(-1)
    outputs = (Matrix.row_vector(hidden_outputs) * Matrix.rows(@hidden_weights)).map {|x| signum(x) }
    outputs.to_a.flatten
  end  
end

class Array
  include PerturbMutation
  include SwapCrossover
  
  def bounds
    unless @bounds
      @bounds = [-10.0..10.0] * size
    end
    @bounds
  end
end

class CharRecognizer < MLP
  include Evaluable
  include PerturbMutation
  include SwapCrossover
  
  CHARCODES = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3,
    "E" => 4
  }
  
  CHARBITSETS = {
    "A" => [
      [0,1,1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1],
      [1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1],
      [0,0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1]
    ],
    "B" => [
      [1,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,1,1,1,1,0],
      [0,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,0],
      [0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,1,1,1,1,0],
    ],
    "C" => [
      [0,1,1,1,0,1,0,0,0,1,1,0,0,0,0,1,0,0,0,1,0,1,1,1,0],
      [0,0,1,1,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,1,0,0,1,1,0],
      [0,0,1,1,1,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1],
    ],
    "D" => [
      [1,1,1,1,0,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0],
      [1,1,1,0,0,1,0,0,1,0,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0],
      [1,1,1,1,0,1,0,0,0,1,1,0,0,0,1,1,0,0,1,0,1,1,1,0,0],  
    ],
    "E" => [
      [1,1,1,1,1,1,0,0,0,0,1,1,1,0,0,1,0,0,0,0,1,1,1,1,1],
      [1,1,1,1,0,1,0,0,0,0,1,1,1,0,0,1,0,0,0,0,1,1,1,1,0],
      [1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,1,0,0,0,0,1,1,1,1,1],
    ]
  }
  
  N_INPUTS = 25
  N_OUTPUTS = Math.log2(CHARCODES.size).ceil
  
  def initialize n_hidden
    super(N_INPUTS,n_hidden,N_OUTPUTS)
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def evaluate
    recognized = 0
    CHARBITSETS.each do |char,bitsets|
      bitsets.each do |bits|
        if recognize(bits) == CHARCODES[char]
          recognized += 1
        end
      end
    end
    recognized
  end
  
  def recognize in_bits
    out_bits = self.forward(in_bits.clone)
    out_bits.inject(0){|r,i| r << 1 | i} # convert array of bits to integer
  end
  
  def mutate
    in_weights.each { |x| x.mutate }
    hidden_weights.each { |x| x.mutate }
  end
  
  def cross other
    a = self.clone
    b = other.clone
    
    in_weights.each_index do |i|
      a.in_weights[i], b.in_weights[i] = in_weights[i].cross(other.in_weights[i])
    end
    
    hidden_weights.each_index do |i|
      a.hidden_weights[i], b.hidden_weights[i] = hidden_weights[i].cross(other.hidden_weights[i])
    end
    
    return a,b
  end
end

TOURNAMENT_SIZE = 10
SELECTION_PROBABILITY = 0.7
CROSSOVER_FRACTION = 0.9
MUTATION_RATE = 0.01
POP_SIZE = 100

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

N_HIDDEN = 10
seed_fn = ->(){ CharRecognizer.new(N_HIDDEN) }
stop_fn = ->(gen,best){ gen > 50 || best.fitness > 6 }
run = experiment.run(POP_SIZE,seed_fn,stop_fn,print_progress:true)
puts "took #{run.best_generation} generations"
binding.pry