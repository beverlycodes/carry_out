require 'test_helper'

class PlanInPlanTest < Minitest::Test
  include CarryOut

  class Message < Unit
    parameter :message

    def execute
      @message
    end
  end

  def test_that_plans_can_be_used_in_place_of_units
    message = 'test'
    message2 = 'test2'

    plan = CarryOut
      .will(Message, as: :test_unit)
      .message(message)
      .then(Message, as: :test_unit2)
      .message(message2)

    plan2 = CarryOut
      .will(plan, as: :plan1)

    result = plan2.execute

    assert_equal message, result.artifacts[:plan1][:test_unit]
    assert_equal message2, result.artifacts[:plan1][:test_unit2]
  end
end
