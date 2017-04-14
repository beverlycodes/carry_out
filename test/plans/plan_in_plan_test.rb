require 'test_helper'

class PlanInPlanTest < Minitest::Test
  include CarryOut

  class RaiseError < Unit
    def call; raise CarryOut::Error, 'Error'; end
  end

  class Message < Unit
    parameter :message

    def call; @message; end
  end

  def test_that_plans_can_be_used_in_place_of_units
    message = 'test'
    message2 = 'test2'

    plan = CarryOut.plan do
      call Message do
        action.message message
        return_as :test_unit
      end

      then_call Message do
        action.message message2
        return_as :test_unit2
      end
    end

    plan2 = CarryOut.plan do
      call plan do
        return_as :plan1
      end
    end

    result = plan2.call

    assert_equal message, result.artifacts[:plan1][:test_unit]
    assert_equal message2, result.artifacts[:plan1][:test_unit2]
  end

  def test_that_embedded_plans_include_errors
    message = 'test'
    message2 = 'test2'

    plan = CarryOut.plan do
      call RaiseError
    end

    plan2 = CarryOut.plan do
      call plan do
        return_as :plan1
      end
    end

    result = plan2.call

    refute result.success?
    assert_equal "Error", result.errors[[:plan1, :_unlabeled]].first.message
  end
end
