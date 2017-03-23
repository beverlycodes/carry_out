require 'test_helper'

class UnitTest < Minitest::Test
  include CarryOut

  class ParameterizedUnit < Unit
    parameter :with_test, :value
  end

  def test_that_parameter_sets_attribute
    value = 'test'
    unit = ParameterizedUnit.new.with_test(value)

    assert_equal value, unit.value
  end
end
