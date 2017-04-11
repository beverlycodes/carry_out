require 'test_helper'

class ConditionalTest < Minitest::Test
  include CarryOut

  class Always < Unit
    def call; true; end
  end

  class Echo < Unit
    parameter :message

    def call; @message end
  end

  class Never < Unit
    def call; false; end
  end

  def test_truthy_conditional
    plan = CarryOut.plan do
      call Always do
        return_as :always
      end

      call Echo do
        message 'test'
        return_as :echo
        only_when context(:always)
      end
    end

    result = plan.call

    assert result.success?
    refute_nil result.artifacts[:echo]
    assert_equal 'test', result.artifacts[:echo]
  end

  def test_truthy_block_conditional
    plan = CarryOut.plan do
      call Always do
        return_as :always
      end

      call Echo do
        message 'test'
        return_as :echo
        only_when { context(:always) }
      end
    end

    result = plan.call

    assert result.success?
    refute_nil result.artifacts[:echo]
    assert_equal 'test', result.artifacts[:echo]
  end

  def test_truthy_exception
    plan = CarryOut.plan do
      call Always do
        return_as :always
      end

      call Echo do
        message 'test'
        return_as :echo
        except_when context(:always)
      end
    end

    result = plan.call

    assert result.success?
    refute result.artifacts.has_key?(:echo)
  end

  def test_falsy_conditional
    plan = CarryOut.plan do
      call Never do
        return_as :never
      end

      call Echo do
        message 'test'
        return_as :echo
        only_when context(:never)
      end
    end

    result = plan.call

    assert result.success?
    refute result.artifacts.has_key?(:echo)
  end

  def test_falsy_block_conditional
    plan = CarryOut.plan do
      call Always do
        return_as :always
      end

      call Echo do
        message 'test'
        return_as :echo
        only_when { context(:never) }
      end
    end

    result = plan.call

    assert result.success?
    refute result.artifacts.has_key?(:echo)
  end

  def test_falsy_exception
    plan = CarryOut.plan do
      call Never do
        return_as :never
      end

      call Echo do
        message 'test'
        return_as :echo
        except_when context(:never)
      end
    end

    result = plan.call

    assert result.success?
    refute_nil result.artifacts[:echo]
    assert_equal 'test', result.artifacts[:echo]
  end
end
