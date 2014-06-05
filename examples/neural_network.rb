require 'genetic_algorithm'
require 'matrix'

include GeneticAlgorithm

# Character recognition using a neural network, where
# NN weights are trained using a genetic algorithm.

class RandomGaussian
  def initialize(mean, stddev, rand_helper = lambda { Kernel.rand })
    @rand_helper = rand_helper
    @mean = mean
    @stddev = stddev
    @valid = false
    @next = 0
  end

  def rand
    if @valid then
      @valid = false
      return @next
    else
      @valid = true
      x, y = self.class.gaussian(@mean, @stddev, @rand_helper)
      @next = y
      return x
    end
  end

  private
  def self.gaussian(mean, stddev, rand)
    theta = 2 * Math::PI * rand.call
    rho = Math.sqrt(-2 * Math.log(1 - rand.call))
    scale = stddev * rho
    x = mean + scale * Math.cos(theta)
    y = mean + scale * Math.sin(theta)
    return x, y
  end
end

class MLP < Array
  @@rg = RandomGaussian.new(0,0.1)
  
  def initialize n_in, n_hidden, n_out
    values = Array.new((n_in+1)*n_hidden + (n_hidden+1)*n_out){ @@rg.rand }
    @n_in = n_in
    @n_hidden = n_hidden
    @n_out = n_out
    @epsilon = 0.0025
    super(values)
  end

  def signum x
    x.map {|el| el > 0.5 ? 1 : 0 }
  end
  
  # x is a vector
  def sigmoid x
    x.map {|el| 0.5 * (1 + Math.tanh(el/@epsilon)) }
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
    inputs = inputs.clone
    
    n_inweights = (@n_in+1) * @n_hidden
    in_weights = Matrix.rows(entries[0...n_inweights].each_slice(@n_hidden).to_a)
    hidden_weights = Matrix.rows(entries[n_inweights..-1].each_slice(@n_out).to_a)
    #in_weights = Matrix.rows(@in_weights)
    #hidden_weights = Matrix.rows(@hidden_weights)
    
    inputs.unshift(-1)
    hidden_outputs = sigmoid(Matrix.row_vector(inputs) * in_weights)
    hidden_outputs = hidden_outputs.to_a.flatten
    
    #binding.pry
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
  include OnepointCrossover
  
  def beta
    0.05
  end
  
  def gamma
    0.01
  end
  
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
  
  CHARS_TO_CODES = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3,
    "E" => 4
  }
  
  CODES_TO_CHARS = {
    0 => "A",
    1 => "B",
    2 => "C",
    3 => "D",
    4 => "E",
  }
  
  N_INPUTS = 25
  N_OUTPUTS = CODES_TO_CHARS.size
  
  def initialize n_hidden
    super(N_INPUTS,n_hidden,N_OUTPUTS)
  end
  
  def []=(pos,val)
    @fitness = nil
    super(pos,val)
  end

  def bounds
    unless @bounds
      @bounds = [-4.0..4.0] * size
    end
    @bounds
  end
  
  def evaluate
    error = 0.0
    CHARBITSETS.each do |char,bitsets|
      bitsets.each do |bits|
        ideal = [0] * CHARS_TO_CODES.size
        ideal[CHARS_TO_CODES[char]] = 1
        ideal = Vector.elements(ideal)
        actual = Vector.elements(self.forward(bits, :linear))
        diff = (ideal - actual)
        error += diff.map2(diff){|el1,el2| el1*el2 }.reduce(0,:+)
      end
    end
    error
  end
  
  def <=> other
    -super(other)
  end
  
  def recognize in_bits
    outs = self.forward(in_bits.clone, :softmax)
    max_idx = outs.each_with_index.max[1]
    return CODES_TO_CHARS[max_idx]
  end  
end

TOURNAMENT_SIZE = 4
SELECTION_PROBABILITY = 0.7
CROSSOVER_FRACTION = 0.98
MUTATION_RATE = 0.005
POP_SIZE = 40
NGEN = 1000

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm)

N_HIDDEN = 6
seed_fn = ->(){ CharRecognizer.new(N_HIDDEN) }
stop_fn = ->(gen,best){ best.fitness < 0.25 }

run = experiment.run(POP_SIZE,seed_fn,stop_fn,print_progress:true)
puts "took #{run.last_generation} generations"
run.plot_all
