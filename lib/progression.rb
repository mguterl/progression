module Progression

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def progression(name, &block)
      (class << self; self; end).send(:define_method, "#{name}_progression") do
        Progression.new(&block)
      end

      define_method("#{name}_progress") do
        self.class.send("#{name}_progression").progress_for(self)
      end
    end

  end

  class Progression

    attr_reader :steps

    def initialize(&block)
      @steps = []
      instance_exec &block if block_given?
    end

    def progress_for(object)
      Progress.new(object, steps)
    end

    private

    def step(name, &block)
      @steps << Step.new(name, &block)
    end

  end

  class Progress

    attr_reader :steps

    def initialize(object, steps)
      @object = object
      @steps = steps
    end

    def completed_steps
      steps.select do |step|
        step.evaluate(@object)
      end
    end

    def percentage_completed
      (completed_steps.size / steps.size.to_f) * 100
    end

    def next_step
      steps.find do |step|
        !step.evaluate(@object)
      end
    end
  end

  class Step

    attr_reader :name

    def initialize(name, &block)
      @name, @block = name, block
    end

    def evaluate(object)
      object.instance_exec &@block
    end

  end

end
