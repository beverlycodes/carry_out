require 'test_helper'

class BoolTest < Minitest::Test
  include CarryOut

  class SetBoolean < Unit
    parameter :is_on

    def execute
      @is_on === true
    end
  end

  def test_that_boolean_parameters_work
    message = 'test'

    plan = CarryOut
      .will(SetBoolean, as: :test_unit)
      .is_on

    result = plan.execute

    assert_same true, result.artifacts[:test_unit]
  end
end
