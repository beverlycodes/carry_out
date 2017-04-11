require 'test_helper'

class CallTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  module Reverse
    class ReverseCharacters < CarryOut::Unit
      parameter :of, :message

      def call; @message.reverse; end
    end
  end

  def test_that_unit_can_be_found_with_syntactic_sugar
    message = 'test'

    plan = CarryOut.plan(search: [ CallTest ]) do
      echo do
        action.message message
        return_as :echo
      end
    end

    result = plan.call

    assert_equal message, result.artifacts[:echo]
  end

  def test_that_unit_can_be_found_with_syntactic_sugar_2
    message = 'test'

    plan = CarryOut.plan(search: [ Reverse ]) do
      reverse_characters do
        of message
        return_as :reverse
      end
    end

    result = plan.call

    assert_equal message.reverse, result.artifacts[:reverse]
  end

  def test_that_unit_can_be_found_with_syntactic_sugar_with_search_proc
    message = 'test'

    plan = CarryOut.plan(search: Proc.new { |name| Reverse::ReverseCharacters }) do
      reverse_characters do
        of message
        return_as :reverse
      end
    end

    result = plan.call

    assert_equal message.reverse, result.artifacts[:reverse]
  end

  def test_that_error_raised_on_nil_search_proc_result
    message = 'test'

    assert_raises NoMethodError do
      plan = CarryOut.plan(search: Proc.new { |name| nil }) do
        reverse_characters do
          of message
        end
      end

      plan.call
    end
  end

  def test_that_error_raised_on_missing_method
    message = 'test'

    assert_raises NoMethodError do
      plan = CarryOut.plan do
        call Echo do
          bad_method context(:nothing)
        end
      end
    end
  end

  def test_that_parameter_can_be_checked_for
    message = 'test'

    plan = CarryOut.plan do
      call Echo do
        if respond_to?(:message)
          message 'test'
        end

        if respond_to?(:not_a_method)
          message 'oops'
        end

        return_as :echo
      end
    end

    result = plan.call

    assert_equal 'test', result.artifacts[:echo]
  end
end
