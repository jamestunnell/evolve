module GeneticAlgorithm
  class TournamentSelector
    def initialize tournament_size, selection_probability
      @k = tournament_size
      @sp = selection_probability
    end
    
    def select potential_competitors, n_winners
      Array.new(n_winners) do |n|
        winner = nil
        while winner.nil?
          # start a new tournament
          competitors = potential_competitors.sample(@k)
          competitors.sort!
          p = @sp
          i = competitors.size - 1
          
          while winner.nil? && i >= 0
            if rand > p
              winner = competitors[i]
            else
              p *= (1-@sp)
            end
            i -= 1
          end
        end
        winner        
      end
    end
  end
end