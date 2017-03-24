require 'test_helper'

class ContextTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute
      @message
    end
  end

  def test_that_plan_can_be_execute_with_passed_context
    input = 'test'
    plan = Plan.new(Echo, as: :echo)
      .message { |refs| refs[:input] }

    result = plan.execute(input: input)

    assert_equal input, result.artifacts[:echo]
  end
end
