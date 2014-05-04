module GeneticAlgorithm
  module Encodings
    class VectorEncoding
      def initialize limits
        @limits = limits
      end
      
      def random_new
        @limits.map { |limit| rand(limit) }
      end
    end
  end
end
