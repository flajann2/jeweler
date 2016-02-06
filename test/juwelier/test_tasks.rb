require 'test_helper'

require 'rake'
class TestTasks < Test::Unit::TestCase
  include Rake

  context 'instantiating Juwelier::Tasks' do
    setup do
      @gemspec_building_block = lambda {|gemspec|}
      @tasks = Juwelier::Tasks.new &@gemspec_building_block
    end

    teardown do
      Task.clear
    end

    should 'assign @gemspec' do
      assert_not_nil @tasks.gemspec
    end

    should 'not eagerly initialize Juwelier' do
      assert ! @tasks.instance_variable_defined?(:@juwelier)
    end

    should 'set self as the application-wide juwelier tasks' do
      assert_same @tasks, Rake.application.juwelier_tasks
    end

    should 'save gemspec building block for later' do
      assert_same @gemspec_building_block, @tasks.gemspec_building_block
    end

    context 'Juwelier instance' do
      setup do
        @tasks.juwelier
      end

      should 'initailize Juwelier' do
        assert @tasks.instance_variable_defined?(:@juwelier)
      end
    end

    should 'yield the gemspec instance' do
      spec = nil
      @tasks = Juwelier::Tasks.new { |s| spec = s }
      assert_not_nil @tasks.juwelier.gemspec
    end

  end
end
