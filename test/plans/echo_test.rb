require 'test_helper'

class EchoTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; { message: @message }; end
  end

  def test_that_unit_receives_parameters
    message = 'test'

    plan = CarryOut.plan(search: [ EchoTest ]) do
      echo do
        action.message context(:message)
        return_as :test_unit
      end
    end

    result = plan.call(message: message)

    assert_equal message, result.artifacts[:test_unit][:message]
  end
end
