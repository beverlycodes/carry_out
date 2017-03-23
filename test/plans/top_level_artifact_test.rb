require 'test_helper'

class TopLevelArtifactTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute(result)
      result.add @message
    end
  end

  def test_that_unit_sets_top_level_artifact
    message = 'test'

    plan = CarryOut
      .will(Echo, as: :message)
      .message(message)

    result = plan.execute

    assert_equal message, result.artifacts[:message]
  end
end
