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
      @percentage_values = {}
      instance_exec &block if block_given?
    end

    def progress_for(object)
      Progress.new(object, self)
    end

    def percentage_value_for(step)
      @percentage_values[step] || (1 / steps.size.to_f) * 100
    end

    private

    def step(name, options = {}, &block)
      step = Step.new(name, &block)
      @steps << step
      @percentage_values[step] = options[:percentage] if options[:percentage]
    end

  end

  class Progress

    attr_reader :steps

    def initialize(object, progression)
      @object = object
      @progression = progression
      @steps = progression.steps
    end

    def completed_steps
      steps.select do |step|
        step.evaluate(@object)
      end
    end

    def percentage_completed
      completed_steps.inject(0) do |percentage_completed, step|
        percentage_completed + @progression.percentage_value_for(step)
      end
    end

    def next_step
      steps.find do |step|
        !step.evaluate(@object)
      end
    end

    def next_step_percentage_completed
      return 100.0 if next_step.nil?
      percentage_completed + @progression.percentage_value_for(next_step)
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

class NilClass

  def blank?
    true
  end unless method_defined?(:blank?)

end

class String

  def blank?
    self !~ /\S/
  end unless method_defined?(:blank?)

end
