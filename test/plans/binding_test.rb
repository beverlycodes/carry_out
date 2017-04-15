require 'test_helper'

class BindingTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def call; @message; end
  end

  def echo(value)
    value
  end

  def test_that_binding_is_maintained_for_single_unit
    test_message = 'test'

    result = CarryOut.call_unit(Echo) do
      message echo(test_message)
      return_as :echo
    end

    assert_equal test_message, result.artifacts[:echo]
  end

  def test_that_binding_is_maintained_in_plan
    test_message = 'test'
    
    plan = CarryOut.plan do
      call Echo do
        message echo(test_message)
        return_as :echo
      end
    end

    result = plan.call

    assert_equal test_message, result.artifacts[:echo]
  end
end
