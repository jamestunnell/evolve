require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SimpleGA do
  describe '.new' do
    it 'should assign arguments to fields' do
      alg = SimpleGA.new("bob",0.5,0.6)
      alg.selector.should eq("bob")
      alg.crossover_fraction.should eq(0.5)
      alg.mutation_rate.should eq(0.6)
    end
  end
end
