require 'test_helper'

class ThenTest < Minitest::Test
  include CarryOut

  class Echo < Unit
    parameter :message

    def execute
      @message
    end
  end

  module Reverse
    class ReverseCharacters < CarryOut::Unit
      parameter :of, :message

      def execute
        @message.reverse
      end
    end
  end

  def test_that_unit_can_be_found_with_syntactic_sugar
    message = 'test'

    plan = CarryOut
      .configured_with(search: [ ThenTest ])
      .will_echo(as: :echo)
      .message(message)

    result = plan.execute

    assert_equal message, result.artifacts[:echo]
  end

  def test_that_unit_can_be_found_with_syntactic_sugar_2
    message = 'test'

    plan = CarryOut
      .configured_with(search: [ Reverse ])
      .will_reverse_characters(as: :reverse)
      .of(message)

    result = plan.execute

    assert_equal message.reverse, result.artifacts[:reverse]
  end

  def test_that_unit_can_be_found_with_syntactic_sugar_with_search_proc
    message = 'test'

    plan = CarryOut
      .configured_with(search: Proc.new { |name| Reverse::ReverseCharacters })
      .will_reverse_characters(as: :reverse)
      .of(message)

    result = plan.execute

    assert_equal message.reverse, result.artifacts[:reverse]
  end

  def test_that_error_raised_on_nil_search_proc_result
    message = 'test'

    assert_raises NoMethodError do
      plan = CarryOut
        .configured_with(search: Proc.new { |name| nil })
        .will_reverse_characters(as: :reverse)
        .of(message)
    end
  end
end
