require 'genetic_algorithm'
require 'matrix'
require 'set'

include GeneticAlgorithm

# Character recognition using a neural network, where
# NN weights are trained using a genetic algorithm.

class MLP < Array
  def initialize n_in, n_hidden, n_out
    values = Array.new((n_in+1)*n_hidden + (n_hidden+1)*n_out){ rand(0.0..0.1) }
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
  
  def beta
    0.1
  end
  
  def gamma
    0.1
  end
  
  def initialize supervised_data, n_hidden, training_fraction = 0.6
    
    vec_sizes = Set.new(supervised_data.values.flatten(1).map {|x| x.size })
    unless vec_sizes.size == 1
      raise ArgumentError, "Inconsistent training/testing vectors length"
    end
    n_inputs = vec_sizes.first
    
    chars = supervised_data.keys
    @n_chars = chars.size
    @codes_to_chars = Hash[ Array.new(@n_chars){|i| [i,chars[i]] } ]
    @chars_to_codes = Hash[ Array.new(@n_chars){|i| [chars[i],i] } ]
    n_outputs = @n_chars
    
    @training_data = Hash[
      supervised_data.map do |char, bitsets|
        n_training = (training_fraction * bitsets.size).round
        if n_training == bitsets.size
          raise ArgumentError, "no bitsets left for testing #{char}"
        end
        training_bitsets = bitsets.sample(n_training)
        [char,training_bitsets]
      end
    ]
    @testing_data = Hash[
      supervised_data.map do |char, bitsets|
        testing_bitsets = bitsets - @training_data[char]
        [char,testing_bitsets]
      end
    ]
    super(n_inputs,n_hidden,n_outputs)
  end
  
  def bounds
    unless @bounds
      @bounds = [-4.0..4.0] * size
    end
    @bounds
  end
  
  def evaluate
    error = 0.0
    @training_data.each do |char,bitsets|
      bitsets.each do |bits|
        ideal = [0] * @chars_to_codes.size
        ideal[@chars_to_codes[char]] = 1
        ideal = Vector.elements(ideal)
        actual = Vector.elements(self.forward(bits, :softmax))
        diff = (ideal - actual)
        error += diff.map2(diff){|el1,el2| el1*el2 }.reduce(0,:+)
      end
    end
    error
  end
  
  def <=>(other)
    -super(other)
  end
  
  def recognize in_bits
    outs = self.forward(in_bits.clone, :softmax)
    max_idx = outs.each_with_index.max[1]
    return @codes_to_chars[max_idx]
  end
  
  def confusion_matrix
    conf_matr = Array.new(@n_chars){Array.new(@n_chars){ 0 }}
    
    @testing_data.each do |char, bitsets|
      actual_class = @chars_to_codes[char]
      bitsets.each do |bitset|
        predicted_char = recognize(bitset)
        predicted_class = @chars_to_codes[predicted_char]
        conf_matr[actual_class][predicted_class] += 1
      end
    end
    
    Matrix.rows(conf_matr)
  end
end

#FIVE_BY_FIVE = {
#  "A" => [
#    [0,1,1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1],
#    [1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1],
#    [0,0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1]
#  ],
#  "B" => [
#    [1,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,1,1,1,1,0],
#    [0,1,1,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,0],
#    [0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,1,1,1,1,0],
#  ],
#  "C" => [
#    [0,1,1,1,0,1,0,0,0,1,1,0,0,0,0,1,0,0,0,1,0,1,1,1,0],
#    [0,0,1,1,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,1,0,0,1,1,0],
#    [0,0,1,1,1,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1],
#  ],
#  "D" => [
#    [1,1,1,1,0,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0],
#    [1,1,1,0,0,1,0,0,1,0,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0],
#    [1,1,1,1,0,1,0,0,0,1,1,0,0,0,1,1,0,0,1,0,1,1,1,0,0],
#  ],
#  "E" => [
#    [1,1,1,1,1,1,0,0,0,0,1,1,1,0,0,1,0,0,0,0,1,1,1,1,1],
#    [1,1,1,1,0,1,0,0,0,0,1,1,1,0,0,1,0,0,0,0,1,1,1,1,0],
#    [1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,1,0,0,0,0,1,1,1,1,1],
#  ]
#}

SEVEN_BY_SEVEN = {
  "A" => [
    [0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1],
    [0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1],
    [0,0,1,1,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1],
    [0,0,1,1,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1],
    [0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1],
    [0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1],
    [0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0],
    [0,0,1,1,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1],
    [0,0,1,1,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0]
  ],
  "B" => [
    [1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,0,1,1,1,1,1,1],
    [0,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1],
  ],
  "C" => [
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,1,1,1,1,0],
    [0,0,1,1,1,1,1,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1],
    [0,0,1,1,1,1,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,1,1,1,1,0],
    [0,0,1,1,1,1,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1]
  ],
  "D" => [
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0],
    [1,1,1,1,1,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,1,0],
    [0,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,0,1,1,1,1,0,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,1,1,1,1,1,0,0],
    [1,1,1,1,1,0,0,1,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0]
  ],
  "E" => [
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1],
    [0,1,1,1,1,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0]
  ]
}

TOURNAMENT_SIZE = 3
SELECTION_PROBABILITY = 0.7
CROSSOVER_FRACTION = 0.7
MUTATION_RATE = 0.05
POP_SIZE = 20
NGEN = 1000

selector = TournamentSelector.new(TOURNAMENT_SIZE, SELECTION_PROBABILITY)
algorithm = SimpleGA.new(selector,CROSSOVER_FRACTION,MUTATION_RATE)
experiment = Experiment.new(algorithm) do |exp|
  exp.update_detail = Experiment::VERBOSE
  exp.update_period = 20
end

N_HIDDEN = 10
TRAINING_FRACTION = 0.6
seed_fn = lambda do
  CharRecognizer.new(SEVEN_BY_SEVEN, N_HIDDEN, TRAINING_FRACTION)
end
stop_fn = ->(gen,best){ best.fitness < 1 }

run = experiment.run(POP_SIZE,seed_fn,stop_fn)
puts "took #{run.last_generation} generations"
run.plot_all
puts run.best_individual.confusion_matrix
