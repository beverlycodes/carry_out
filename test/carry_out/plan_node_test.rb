require 'test_helper'

class PlanNodeTest < Minitest::Test
  include CarryOut

  def test_that_method_missing_defaults_to_super_on_non_parameter_method
    assert_raises NoMethodError do
      PlanNode.new.bad_method(0, 0)
    end
  end
end
