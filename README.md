# progression

progression provides a set of simple utility classes and a DSL for
measuring an objects progress through a progression of steps.  This is
especially useful for defining and calculating profile completion
status in a social application.

There are a few existing solutions similar to progression, but they
try to do too much.  The other options that I am familiar with are
either coupled with ActiveRecord or ActionController in some way.

## DSL syntax

    class User < Struct.new(:first_name, :last_name, :email, :phone)

      include Progression

      progression :registration do
        step :step_1 do
          first_name.present? && last_name.present?
        end

        step :step_2 do
          email.present? && phone.present?
        end
      end
    end

    user = User.new
    user.registration_progress.completed_steps # => []
    user.registration_progress.percentage_complete # => 0.0
    user.next_step.name # => :step_1

    user.first_name = "Michael"
    user.last_name  = "Jordan"
    user.registration_progress.completed_steps # => [:step_1]
    user.registration_progress.percentage_complete # => 50.0
    user.next_step.name # => :step_2

    ...


## Utility classes

    registration = Progression::Progression.new
    registration.steps << Progression::Step.new(:step_1) { !first_name.blank? && !last_name.blank? }
    registration.steps << Progression::Step.new(:step_2) { !email.blank? && !phone.blank? }

    User = Struct.new(:first_name, :last_name, :email, :phone)
    user = User.new

    progress = registration.progress_for(user)
    progress.completed_steps # => []
    progress.percentage_completed # => 0.0
    progress.next_step.name # => :step_1

    user.first_name = "Michael"
    user.last_name  = "Jordan"

    progress.completed_steps # => [:step_1]
    progress.percentage_completed # => 50.0
    progress.next_step.name # => :step_2

    user.email = "michael@jordan.com"
    user.phone = "513-347-1111"

    progress.completed_steps # => [:step_1, :step_2]
    progress.percentage_completed # => 100.0
    progress.next_step # => nil

## Rails / ActiveRecord

You can use progression as a gem or a plugin in your Rails application.  progression does not make any assumptions about the objects that you are interested in extending.

Simply add an initializer:

config/initializers/progression.rb

    ActiveRecord::Base.send(:include, Progression)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Michael Guterl. See LICENSE for details.
