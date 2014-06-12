require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UniformMutation do
  describe '#mutate' do
    before :all do
      @start_values = Array.new(100){|i| rand(0...50) }
      @a = Array.new(@start_values)
      def @a.bounds
        return [0...50]*100
      end
      @a.extend(UniformMutation)
      @a.mutate!(0)
    end
    
    it 'should cause some modification' do
      @a.should_not eq(@start_values)
    end
    
    it 'should modify exactly one element' do
      differences = 0
      @a.each_index do |i|
        if @a[i] != @start_values[i]
          differences += 1
        end
      end
      differences.should eq(1)
    end
  end
end
