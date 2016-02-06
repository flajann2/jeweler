require 'rake'
require 'rake/tasklib'

class Juwelier
  # Rake tasks for putting a Juwelier gem on Gemcutter.
  #
  # Juwelier::Tasks.new needs to be used before this.
  #
  # Basic usage:
  #
  #     Juwelier::RubygemsDotOrgTasks.new
  #
  # Easy enough, right?
  class RubygemsDotOrgTasks < ::Rake::TaskLib
    attr_accessor :jeweler

    def initialize
      yield self if block_given?

      define
    end

    def jeweler
      @jeweler ||= Rake.application.jeweler
    end

    def define
      namespace :rubygems do
        desc "Release gem to Gemcutter"
        task :release => [:gemspec, :build] do
          jeweler.release_gem_to_rubygems
        end
      end

      task :release => 'rubygems:release'
    end
  end
end
