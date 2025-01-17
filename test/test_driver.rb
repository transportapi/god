# frozen_string_literal: true

require_relative 'helper'

class TestDriver < Minitest::Test
  def setup
  end

  def test_push_pop_wait
    eq = God::DriverEventQueue.new
    cond = eq.instance_variable_get(:@resource)
    cond.expects(:wait).times(1)

    eq.push(God::TimedEvent.new(0))
    eq.push(God::TimedEvent.new(0.1))
    t = Thread.new do
      # This pop will see an event immediately available, so no wait.
      assert_equal TimedEvent, eq.pop.class

      # This pop will happen before the next event is due, so wait.
      assert_equal TimedEvent, eq.pop.class
    end

    t.join
  end
end
