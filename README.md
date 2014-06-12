evolve
======

* [Homepage](https://rubygems.org/gems/evolve)
* [Documentation](http://rubydoc.info/gems/evolve/frames)
* [Email](mailto:jamestunnell@gmail.com)

## Description

Basic genetic algorithm framework, suitable for most experiments.

## Examples

<pre><code>
  require 'evolve'
  include Evolve
  
  # Minimize the function f(x,y) = x - 2y, f(x,y) >= 0, x,y in [-512,512]
  class Individual < Array
    include Evaluable
    include UniformMutation
    include OnepointCrossover

    BOUNDS = [-512..512,-512..512]
  
    attr_reader :bounds
    def initialize values=[]
      @bounds = BOUNDS
      unless values.any?
        values = @bounds.map {|bound| rand(bound) }
      end
      super(values)
    end
  
    def clone
      Individual.new(entries)
    end
  
	# 
    def evaluate
      (entries[0] - 2*entries[1]).abs
    end
  
    def <=>(other)
      -super(other)
    end
  end

  TOURN_SIZE, SEL_PROB = 4, 0.6
  CROSSOVER_FRAC, MUT_RATE = 0.9, 0.01
  
  selector = TournamentSelector.new(TOURN_SIZE, SEL_PROB)
  algorithm = SimpleGA.new(selector, CROSSOVER_FRAC, MUT_RATE)
  experiment = Experiment.new(algorithm)
  
  wait_for_optimal = ->(gen,best){ best.fitness == 0 }
  new_individual = ->(){ Individual.new }  # assumes Individual class was already defined
  
  POP_SIZE = 40
  run = experiment.run(POP_SIZE, new_individual, wait_for_optimal)
  run.plot_fitness
</code>
</pre>

## Requirements

Depends on the `gnuplot` gem. If plotting functions are actually going to be used, then Gnuplot must also be installed.

## Install

  $ gem install evolve

## Copyright

Copyright (c) 2014 James Tunnell

See LICENSE.txt for details.
