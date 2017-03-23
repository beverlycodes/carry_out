require 'test_helper'

class PlanTest < Minitest::Test
  include CarryOut

  def setup
    @plan = CarryOut.will
  end

  def test_that_execute_returns_a_result
    result = @plan.execute
    assert_kind_of Result, result
    assert result.success?, 'Expected execution to be successful'
  end

  def test_that_execute_result_can_be_consumed_in_block
    @plan.execute do |result|
      assert_kind_of Result, result
    end
  end

  def test_that_plan_fails_normally_on_missing_method
    assert_raises NoMethodError do
      @plan.bad_method
    end
  end

  def test_that_plan_can_be_created_with_unit
    assert Plan.new(Object.new)
  end

  def test_that_plan_can_be_created_with_unit_and_options
    assert Plan.new(Object.new, as: 'object')
  end
end
