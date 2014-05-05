require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TournamentSelector do
  describe '#select' do
    before :all do
      @pool = (0..20).to_a
      @selector = TournamentSelector.new(4,0.5)
    end
    
    it 'should return winners who belong to the given pool of competitors' do
      winners = @selector.select(@pool, 6)
      @pool.should include(*winners)
    end
    
    it 'should return as many winners as given' do
      winners = @selector.select(@pool, 7)
      winners.size.should eq(7)
    end
  end
end
