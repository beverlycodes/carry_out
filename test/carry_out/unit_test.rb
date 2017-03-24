require 'test_helper'

class UnitTest < Minitest::Test
  include CarryOut

  class ParameterizedUnit < Unit
    parameter :with_test, :value
    appending_parameter :and_test, :value
  end

  def test_that_parameter_sets_attribute
    value = 'test'
    unit = ParameterizedUnit.new.with_test(value)

    assert_equal value, unit.value
  end

  def test_that_appending_parameter_converts_to_array
    value = 'test'
    value2 = 'test2'
    unit = ParameterizedUnit.new
      .with_test(value)
      .and_test(value2)

    assert_kind_of Array, unit.value
    assert_includes unit.value, value
    assert_includes unit.value, value2
  end
end
