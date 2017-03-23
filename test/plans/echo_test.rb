require 'test_helper'

class EchoTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute
      { message: @message }
    end
  end

  def test_that_unit_receives_parameters
    message = 'test'

    plan = CarryOut
      .will(Echo, as: :test_unit)
      .message(message)

    result = plan.execute

    assert_equal message, result.artifacts[:test_unit][:message]
  end
end
