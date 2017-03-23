require 'test_helper'

class CarryOutTest < Minitest::Test
  class Echo < CarryOut::Unit
    parameter :message

    def execute
      @message
    end
  end

  class Context
    def execute
      yield test: 'test'
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::CarryOut::VERSION
  end

  def test_that_will_returns_a_plan_instance
    plan = CarryOut.will
    assert plan.instance_of?(CarryOut::Plan)
  end

  def test_that_plan_can_execute_within_a_context
    plan = CarryOut
      .within(Context.new)
      .will(Echo, as: :echo)
      .message { |refs| refs[:test] }

    result = plan.execute
    assert_equal 'test', result.artifacts[:echo]
  end
end
