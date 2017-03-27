require 'test_helper'

class ReferencesTest < Minitest::Test
  include CarryOut

  class Send < Unit
    parameter :message

    def execute
      @message
    end
  end

  class Receive < Unit
    parameter :message

    def execute
      @message
    end
  end

  def test_that_unit_references_are_accessible_in_blocks
    message = 'test'

    plan = CarryOut
      .will(Send, as: :send)
      .message(message)
      .then(Receive, as: :receive)
      .message { |refs| refs[:send] }

    plan.execute do |result|
      assert_equal message, result.artifacts[:receive]
    end
  end

  def test_that_unit_references_are_accessible_via_reference_resolver
    message = 'test'

    plan = CarryOut
      .will(Send, as: :send)
      .message(message)
      .then(Receive, as: :receive)
      .message(CarryOut.get(:send))

    plan.execute do |result|
      assert_equal message, result.artifacts[:receive]
    end
  end

  def test_that_plan_does_not_allow_passing_resolver_and_block
    message = 'test'

    assert_raises ArgumentError do
      plan = CarryOut
        .will(Send, as: :send)
        .message(CarryOut.get(:message)) { |refs| refs[:message] }
    end
  end

  def test_that_plan_does_not_allow_passing_value_and_block
    message = 'test'

    assert_raises ArgumentError do
      plan = CarryOut
        .will(Send, as: :send)
        .message(message) { |refs| refs[:message] }
    end
  end

  def test_that_reference_resolver_returns_nil_for_bad_keys
    message = 'test'

    plan = CarryOut
      .will(Send, as: :send)
      .message(message)
      .then(Receive, as: :receive)
      .message(CarryOut.get(:send, :test))

    plan.execute do |result|
      assert_nil result.artifacts[:receive]
    end
  end

  def test_that_unit_references_are_accessible_via_magic_block_method
    message = 'test'

    plan = CarryOut
      .configured_with(search: [ ReferencesTest ])
      .will_send
        .message { result_of_message }
        .returning_as_send
      .then_receive
        .message { result_of_send }
        .returning_as_receive

    plan.execute(message: message) do |result|
      assert_equal message, result.artifacts[:receive]
    end
  end
end
