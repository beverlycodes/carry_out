require 'test_helper'

class MultiUnitTest < Minitest::Test
  include CarryOut

  class Message < Unit
    parameter :message

    def execute(result)
      result.add(:message, @message)
    end
  end

  def test_that_execution_flows_through_multiple_units
    message = 'test'
    message2 = 'test2'

    plan = CarryOut
      .will(Message, as: :test_unit)
      .message(message)
      .then(Message, as: :test_unit2)
      .message(message2)

    result = plan.execute

    assert_equal message, result.artifacts[:test_unit][:message]
    assert_equal message2, result.artifacts[:test_unit2][:message]
  end
end
