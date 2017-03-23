require 'test_helper'

class ReferencesTest < Minitest::Test
  include CarryOut

  class Send < Unit
    parameter :message

    def execute(result)
      result.add(:message, @message)
    end
  end

  class Receive < Unit
    parameter :message

    def execute(result)
      result.add(:message, @message)
    end
  end

  def test_that_unit_references_are_accessible_in_blocks
    message = 'test'

    plan = CarryOut
      .will(Send, as: :send)
      .message(message)
      .then(Receive, as: :receive)
      .message { |refs| refs[:send][:message] }

    plan.execute do |result|
      assert_equal message, result.artifacts[:receive][:message]
    end
  end
end
