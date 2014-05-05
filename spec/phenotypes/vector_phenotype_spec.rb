require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VectorPhenotype do
  describe '#new' do
    it 'should create an array as long as the given bounds' do
      VectorPhenotype.new([0..4,5..40], ->(x){ 0 }).size.should eq(2)
    end
  end
  
  describe '#clone' do
    it 'should create an identical object' do
      a = VectorPhenotype.new([0..4,5..40], ->(x){ 0 })
      b = a.clone
      a.should eq(b)
    end
  end

  it 'should be able to extend OnepointCrossover' do
    bounds = [0..4,5..40]
    a = VectorPhenotype.new(bounds, ->(x){ 0 })
    b = VectorPhenotype.new(bounds, ->(x){ 0 })
    a.extend(OnepointCrossover)
    expect { a.cross(b) }.to_not raise_error
  end
  
  it 'should be able to extend TwopointCrossover' do
    bounds = [0..4,5..40,6..10]
    a = VectorPhenotype.new(bounds, ->(x){ 0 })
    b = VectorPhenotype.new(bounds, ->(x){ 0 })
    a.extend(TwopointCrossover)
    expect { a.cross(b) }.to_not raise_error
  end
    
  it 'should be able to extend UniformMutation' do
    a = VectorPhenotype.new([0..4,5..40], ->(x){ 0 })
    a.extend(UniformMutation)
    expect { a.mutate }.to_not raise_error
  end
end
