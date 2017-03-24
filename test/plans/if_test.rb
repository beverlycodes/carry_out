require 'test_helper'

class IfTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute
      @message
    end
  end

  def test_that_nodes_guarded_by_if_can_execute
    plan = Plan.new(Echo, as: :echo)
      .message('test')
      .if { |refs| true }

    result = plan.execute

    refute_nil result.artifacts[:echo]
    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_nodes_guarded_by_unless_can_execute
    plan = Plan.new(Echo, as: :echo)
      .message('test')
      .unless { |refs| false }

    result = plan.execute

    refute_nil result.artifacts[:echo]
    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_nodes_can_be_skipped_with_if
    plan = Plan.new(Echo, as: :echo)
      .message('test')
      .if { |refs| false }

    result = plan.execute

    assert_nil result.artifacts[:echo]
  end

  def test_that_nodes_can_be_skipped_with_unless
    plan = Plan.new(Echo, as: :echo)
      .message('test')
      .unless { |refs| true }

    result = plan.execute

    assert_nil result.artifacts[:echo]
  end

  def test_that_guards_receive_artifacts
    plan = Plan.new(Echo, as: :echo)
      .message('test')
      .unless { |refs| refs[:silent] }

    result = plan.execute(silent: true)

    assert_nil result.artifacts[:echo]
  end
end
