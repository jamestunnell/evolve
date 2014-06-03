require 'genetic_algorithm'
require 'matrix'

require 'pry'

include GeneticAlgorithm

# Character recognition using a neural network, where
# NN weights are trained using a genetic algorithm.

class Array
end

class MLP < Array  
  def initialize n_in, n_hidden, n_out
    n_weights = (n_in+1) * n_hidden + (n_hidden+1)*n_out
    values = Array.new(n_weights){ rand-0.5 }
    @n_in = n_in
    @n_hidden = n_hidden
    @n_out = n_out
    @beta = 1
    super(values)
  end

  def signum x
    x.map {|el| el > 0 ? 1 : 0 }
  end
  
  # x is a vector
  def sigmoid x
    x.map {|el| 1.0 / (1.0 + Math.exp(-@beta * el)) }
  end
  
  # x is a vector
  def softmax x
    exps = x.map {|el| Math.exp(el)}
    normaliser = exps.inject(0,:+)
    return exps / normaliser
  end
  
  def forward inputs, out_function = :linear
    unless inputs.size == @n_in
      raise ArgumentError, "Input size is #{inputs.size}, but should be #{@n_in}"
    end
    
    n_inweights = (@n_in+1) * @n_hidden
    in_weights = Matrix.rows(entries[0...n_inweights].each_slice(@n_hidden).to_a)
    hidden_weights = Matrix.rows(entries[n_inweights..-1].each_slice(@n_out).to_a)
    
    inputs.unshift(-1)
    hidden_outputs = sigmoid(Matrix.row_vector(inputs) * in_weights)
    hidden_outputs = hidden_outputs.to_a.flatten
    
    hidden_outputs.unshift(-1)
    outputs = (Matrix.row_vector(hidden_outputs) * hidden_weights)
    
    outputs = case out_function
    when :linear then outputs
    when :sigmoid then sigmoid(outputs)
    when :softmax then softmax(outputs)
    when :signum  then signum(outputs)
    else
      raise ArgumentError, "Unkown out function #{out_function}"
    end
    outputs.to_a.flatten
  end  
end

class CharRecognizer < MLP
  include Evaluable
  include PerturbMutation
  include TwopointCrossover
  
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
  
  CHARCODES = {
    0 => "A",
    1 => "B",
    2 => "C",
    3 => "D",
    4 => "E",
  }
  
  N_INPUTS = 25
  N_OUTPUTS = 5
  
  def initialize n_hidden
    super(N_INPUTS,n_hidden,N_OUTPUTS)
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end

  def bounds
    unless @bounds
      @bounds = [-1.0..1.0] * size
    end
    @bounds
  end
  
  def evaluate
    recognized = 0
    CHARBITSETS.each do |char,bitsets|
      bitsets.each do |bits|
        if recognize(bits) == char
          recognized += 1
        end
      end
    end
    recognized
  end
  
  def recognize in_bits
    outs = self.forward(in_bits.clone, :softmax)
    max_idx = outs.each_with_index.max[1]
    return CHARCODES[max_idx]
    #maxout_bits = outs.map {|out| out.round }
    #out_bits.inject(0){|r,i| r << 1 | i} # convert array of bits to integer
  end  
end

TOURNAMENT_SIZE = 4
SELECTION_PROBABILITY = 0.6
CROSSOVER_FRACTION = 0.9
MUTATION_RATE = 0.01
POP_SIZE = 24

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

N_HIDDEN = 10
seed_fn = ->(){ CharRecognizer.new(N_HIDDEN) }
stop_fn = ->(gen,best){ gen > 500 || best.fitness > 6 }
run = experiment.run(POP_SIZE,seed_fn,stop_fn,print_progress:true)
puts "took #{run.generations.last} generations"
