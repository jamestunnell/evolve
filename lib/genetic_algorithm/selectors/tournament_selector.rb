module GeneticAlgorithm
  module Selectors
    class TournamentSelector
      def initialize tournament_size, selection_probability
        @k = tournament_size
        @p = selection_probability
      end
      
      def select population, n_competitions
        Array.new(n_competitions) do |i|
          winner = nil
          while winner.nil?
            winner = compete(population.sample(@k))
          end
          winner
        end
      end
      
      def compete(competitors)
        competitors.sort!
        winner = nil
        p = @p
        i = competitors.size - 1
        
        while winner.nil? && i >= 0
          if rand > p
            winner = competitors[i]
          else
            p *= (1-@p)
          end
          i -= 1
        end
        
        return winner
      end
    end
  end
end