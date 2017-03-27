require 'test_helper'

class UnitTest < Minitest::Test
  include CarryOut

  class ParameterizedUnit < Unit
    parameter :with_test, :value
    appending_parameter :and_test, :value

    def execute; @value; end
  end

  def test_that_unit_has_parameter_method
    value = 'test'
    unit = ParameterizedUnit.new.with_test(value)

    assert_respond_to unit, :with_test

    result = unit.execute
    assert_equal value, result
  end

  def test_that_appending_parameter_converts_to_array
    value = 'test'
    value2 = 'test2'
    result = ParameterizedUnit.new
      .with_test(value)
      .and_test(value2)
      .execute

    assert_kind_of Array, result
    assert_includes result, value
    assert_includes result, value2
  end

  def test_that_appending_parameter_works_in_isolation
    value = 'test'

    result = ParameterizedUnit.new
      .and_test(value)
      .execute

    assert_kind_of Array, result
    assert result.length == 1, "Expected length of #{result.length} to be 1"
    assert_includes result, value
  end

  def test_that_explicit_nil_is_appended_to
    value = 'test'

    result = ParameterizedUnit.new
      .with_test(nil)
      .and_test(value)
      .execute

    assert_kind_of Array, result
    assert result.length == 2, "Expected length of #{result.length} to be 2"
    assert_includes result, nil
    assert_includes result, value
  end

  def test_that_boolean_parameter_can_chain
    result = ParameterizedUnit.new
      .with_test
      .and_test('test')
      .execute

    assert_equal [ true, 'test' ], result
  end
end
