require 'test_helper'

class ErrorTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute(result)
      result.add(:message, @message)
    end
  end

  class RaiseError < Unit
    def execute(result)
      raise StandardError.new('Raised an error')
    end
  end

  def test_that_expected_errors_are_added_to_result
    plan = CarryOut.will(RaiseError, as: :test_unit)
    result = plan.execute

    refute result.errors[:test_unit].empty?
    assert_equal 'Raised an error', result.errors[:test_unit].first.message
    assert_instance_of StandardError, result.errors[:test_unit].first.details
  end

  def test_that_execution_ends_after_error
    plan = CarryOut
      .will(RaiseError, as: :test_unit)
      .then(Echo)
      .message { |refs| flunk "Execution should have stopped" }

    result = plan.execute
  end
end
