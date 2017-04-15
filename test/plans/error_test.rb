require 'test_helper'

class ErrorTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  class RaiseError < Unit
    def call; raise CarryOut::Error.new('Raised an error'); end
  end

  class ReturnError < Unit
    def call; 2.times.map { CarryOut::Error.new('Returned an error') }; end
  end

  def test_that_expected_errors_are_added_to_result
    plan = CarryOut.plan do
      call RaiseError do
        return_as :test_unit
      end
    end

    result = plan.call

    refute result.errors.empty?
    assert_equal 1, result.errors.length

    error = result.errors[:test_unit].first

    assert_equal 'Raised an error', error.message
  end

  def test_that_execution_ends_after_raised_error
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

  def test_that_multiple_errors_can_be_returned
    plan = CarryOut.plan do
      call ReturnError do
        return_as :test_unit
      end
    end

    result = plan.call
    refute result.success?, "Expected result to indicate failure"
    refute_empty result.errors
    assert_equal 2, result.errors[:test_unit].length
  end
end
