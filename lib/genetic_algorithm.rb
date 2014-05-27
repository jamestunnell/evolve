require 'genetic_algorithm/version'

require 'genetic_algorithm/evaluable'
require 'genetic_algorithm/mutations/uniform_mutation'
require 'genetic_algorithm/mutations/swap_mutation'
require 'genetic_algorithm/crossovers/onepoint_crossover'
require 'genetic_algorithm/crossovers/twopoint_crossover'
require 'genetic_algorithm/crossovers/swap_crossover'

require 'genetic_algorithm/phenotypes/vector_phenotype'

require 'genetic_algorithm/selectors/tournament_selector'
require 'genetic_algorithm/algorithms/simple_ga'

require 'genetic_algorithm/experimentation/run'
require 'genetic_algorithm/experimentation/run_set'
require 'genetic_algorithm/experimentation/experiment'
