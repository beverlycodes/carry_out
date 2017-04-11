require 'test_helper'

class HelloTest < Minitest::Test
  include CarryOut

  class Hello < Unit
    def call; 'Hello'; end
  end

  def test_that_unit_adds_artifact_to_result
    plan = CarryOut.plan do
      call(Hello) { return_as :test_unit }
    end

    result = plan.call

    refute_nil result.artifacts[:test_unit]
    assert_equal 'Hello', result.artifacts[:test_unit]
  end
end
