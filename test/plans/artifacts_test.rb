require 'test_helper'

class ArtifactsTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  class EchoToHash < Unit
    parameter :key
    parameter :message

    def call; Hash[@key, @message]; end
  end

  def test_that_returning_as_sets_context_key
    message = 'test'

    plan = CarryOut.plan do
      call Echo do
        action.message message
        return_as :echo
      end
    end

    result = plan.call

    assert_equal message, result.artifacts[:echo]
  end

  def test_that_hashes_are_merged
    message = 'test'

    plan = CarryOut.plan do
      call EchoToHash do
        key :message1
        action.message message
        return_as :echo
      end

      then_call EchoToHash do
        key :message2
        action.message message
        return_as :echo
      end
    end

    result = plan.call(message: message)

    assert_equal message, result.artifacts[:echo][:message1]
    assert_equal message, result.artifacts[:echo][:message2]
  end

  def test_that_repeat_label_is_overwritten
    message = 'test'
    message2 = 'test2'

    plan = CarryOut.plan do
      call Echo do
        action.message message
        return_as :echo
      end

      then_call Echo do
        action.message message2
        return_as :echo
      end
    end

    result = plan.call

    assert_equal message2, result.artifacts[:echo]
  end

  def test_that_return_value_can_be_refined_by_block
    message = 'test'

    plan = CarryOut.plan do
      call EchoToHash do
        key :echo_key
        action.message message
        return_as (:echo) { |result| result[:echo_key] }
      end
    end

    result = plan.call

    assert_equal message, result.artifacts[:echo]
  end
end
