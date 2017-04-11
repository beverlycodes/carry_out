require 'test_helper'

class ErrorTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  class RaiseError < Unit
    def call; raise StandardError.new('Raised an error'); end
  end

  def test_that_expected_errors_are_added_to_result
    plan = CarryOut.plan do
      call RaiseError do
        return_as :test_unit
      end
    end

    result = plan.call

    refute result.errors[:test_unit].empty?
    assert_equal 'Raised an error', result.errors[:test_unit].first.message
    assert_instance_of StandardError, result.errors[:test_unit].first.details
  end

  def test_that_execution_ends_after_error
    plan = CarryOut.plan do
      call RaiseError do
        return_as :test_unit
      end

      call Echo do
        message 'test'
        return_as :echo
      end
    end

    result = plan.call
    refute result.success?, "Expected result to indicate failure"
    assert_nil result.artifacts[:echo]
  end
end
