require 'test_helper'

class ArtifactsTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute
      @message
    end
  end

  class EchoToHash < Unit
    parameter :key
    parameter :message

    def execute
      Hash[@key, @message]
    end
  end

  def test_that_returning_as_sets_context_key
    message = 'test'

    plan = CarryOut
      .will(Echo)
      .message(message)
      .returning_as_message

    result = plan.execute

    assert_equal message, result.artifacts[:message]
  end

  def test_that_unit_sets_top_level_artifact
    message = 'test'

    plan = CarryOut
      .will(Echo, as: :message)
      .message(message)

    result = plan.execute

    assert_equal message, result.artifacts[:message]
  end

  def test_that_hashes_are_merged
    message = 'test'

    plan = CarryOut
      .will(EchoToHash, as: :echo)
        .key(:message1)
        .message(message)
      .then(EchoToHash, as: :echo)
        .key(:message2)
        .message(message)

    result = plan.execute

    assert_equal message, result.artifacts[:echo][:message1]
    assert_equal message, result.artifacts[:echo][:message2]
  end

  def test_that_repeat_label_becomes_array
    message = 'test'

    plan = CarryOut
      .will(Echo, as: :echo).message(message)
      .then(Echo, as: :echo).message(message)

    result = plan.execute

    assert_kind_of Array, result.artifacts[:echo]
    assert_equal message, result.artifacts[:echo][0]
    assert_equal message, result.artifacts[:echo][1]
  end
end
