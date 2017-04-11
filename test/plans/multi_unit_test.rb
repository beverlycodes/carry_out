require 'test_helper'

class MultiUnitTest < Minitest::Test
  include CarryOut

  class Message < Unit
    parameter :message

    def call; @message; end
  end

  def test_that_execution_flows_through_multiple_units
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

    result = plan.call

    assert_equal message, result.artifacts[:test_unit]
    assert_equal message2, result.artifacts[:test_unit2]
  end
end
