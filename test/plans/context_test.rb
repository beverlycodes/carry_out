require 'test_helper'

class ContextTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  class EchoHash < Unit
    parameter :key
    parameter :message

    def call
      Hash[@key, @message]
    end
  end

  def test_that_plan_can_be_execute_with_passed_context
    input = 'test'
    plan = CarryOut.plan do
      call Echo do
        message context(:input)
        return_as :echo
      end
    end

    result = plan.call(input: input)

    assert_equal input, result.artifacts[:echo]
  end

  def test_that_context_supports_deep_keys
    input = 'test'
    plan = CarryOut.plan do
      call EchoHash do
        key :test
        message context(:input)
        return_as :echo_hash
      end

      call Echo do
        message context(:echo_hash, :test)
        return_as :echo
      end
    end

    result = plan.call(input: input)

    assert_equal input, result.artifacts[:echo]
  end

  def test_that_context_returns_nil_for_missing_deep_keys
    input = 'test'
    plan = CarryOut.plan do
      call Echo do
        message context(:not, :a, :real, :key)
        return_as :echo
      end
    end

    result = plan.call(input: input)

    assert_nil result.artifacts[:echo]
  end

  def test_that_context_works_in_blocks
    input = 'test'

    plan = CarryOut.plan do
      call Echo do
        message { context(:input) }
        return_as :echo
      end
    end

    result = plan.call(input: input)

    assert_equal input, result.artifacts[:echo]
  end
end
