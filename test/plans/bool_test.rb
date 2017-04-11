require 'test_helper'

class BoolTest < Minitest::Test
  include CarryOut

  class SetBoolean < Unit
    parameter :is_on

    def call; @is_on === true; end
  end

  def test_that_boolean_parameters_work
    message = 'test'

    plan = CarryOut.plan do
      call SetBoolean do
        is_on
        return_as :test_unit
      end
    end

    result = plan.call

    assert_same true, result.artifacts[:test_unit]
  end
end
