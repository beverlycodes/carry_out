require 'test_helper'

class HelloTest < Minitest::Test
  include CarryOut

  class Hello < Unit
    def execute
      'Hello'
    end
  end

  def test_that_unit_adds_artifact_to_result
    plan = CarryOut.will(Hello, as: :test_unit)
    result = plan.execute

    refute_nil result.artifacts[:test_unit]
    assert_equal 'Hello', result.artifacts[:test_unit]
  end
end
