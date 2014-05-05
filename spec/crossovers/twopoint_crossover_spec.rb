require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TwopointCrossover do
  describe '#cross' do
    before :all do
      @a, @b = [1,2,3,4],[5,6,7,8]
      @a.extend(TwopointCrossover)
      @b.extend(TwopointCrossover)
      @results = @a.cross(@b)
    end
    
    it 'should return two objects' do
      @results.size.should eq(2)
    end
    
    it 'should return objects of same type as inputs' do
      c, d = @results
      c.should be_a(@a.class)
      d.should be_a(@a.class)
    end
  end
end
