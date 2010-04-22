require 'spec/spec_helper'

class Profile < Struct.new(:first_name, :last_name)

  include Progression

  progression :profile do

    step :step_1 do
      !first_name.blank?
    end

    step :step_2 do
      !last_name.blank?
    end

  end

  # def self.profile_progression
  #   @progression ||= Progression::Progression.new do
  #     steps << Progression::Step.new(:step_1) { !first_name.blank? }
  #     steps << Progression::Step.new(:step_2) { !last_name.blank? }
  #   end
  # end

  # def profile_progress
  #   self.class.profile_progression.progress_for(self)
  # end

end

describe "Progression" do

  before do
    @profile = Profile.new
    @progression = @profile.profile_progress
  end

  it 'should return a list of steps' do
    @progression.should have(2).steps
  end

  it 'should return a list of completed steps' do
    @progression.should have(0).completed_steps
  end

  it 'should return the percentage completed' do
    @progression.percentage_completed.should == 0.0
  end

  it 'should return the next step to be completed' do
    @progression.next_step.name.should == :step_1
  end

  describe "after first step" do

    before do
      @profile.first_name = "Michael"
      @progression = @profile.profile_progress
    end

    it 'should have 1 completed step' do
      @progression.should have(1).completed_steps
    end

    it 'should return the percentage completed' do
      @progression.percentage_completed.should == 50.0
    end

    it 'should return the next step to be completed' do
      @progression.next_step.name.should == :step_2
    end

    describe "and second step" do

      before do
        @profile.last_name = "Jordan"
        @progression = @profile.profile_progress
      end

      it 'should have 1 completed step' do
        @progression.should have(2).completed_steps
      end

      it 'should return the percentage completed' do
        @progression.percentage_completed.should == 100.0
      end

      it 'should return nil when there are no more steps to be completed' do
        @progression.next_step.should == nil
      end

    end

  end

end
