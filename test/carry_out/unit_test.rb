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

  def test_that_parameter_provides_attribute_writer
    unit = ParameterizedUnit.new
    assert unit.respond_to?('value=')
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

  def test_that_appending_parameter_works_in_isolation
    value = 'test'

    unit = ParameterizedUnit.new
      .and_test(value)

    assert_kind_of Array, unit.value
    assert unit.value.length == 1, "Expected length of #{unit.value.length} to be 1"
    assert_includes unit.value, value
  end

  def test_that_explicit_nil_is_appended_to
    value = 'test'

    unit = ParameterizedUnit.new
      .with_test(nil)
      .and_test(value)

    assert_kind_of Array, unit.value
    assert unit.value.length == 2, "Expected length of #{unit.value.length} to be 2"
    assert_includes unit.value, nil
    assert_includes unit.value, value
  end
end
