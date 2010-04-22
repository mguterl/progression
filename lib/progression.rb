module Progression

  class Progress

    attr_reader :steps

    def initialize(object, &block)
      @object = object
      @steps = []
      instance_exec &block
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

    private
    def step(name, &block)
      @steps << Step.new(name, &block)
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
