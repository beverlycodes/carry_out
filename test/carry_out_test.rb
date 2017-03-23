require 'test_helper'

class CarryOutTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CarryOut::VERSION
  end

  def test_that_first_returns_a_plan_instance
    plan = CarryOut.will
    assert plan.instance_of?(CarryOut::Plan)
  end
end
