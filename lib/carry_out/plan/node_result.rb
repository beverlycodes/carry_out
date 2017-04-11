module CarryOut
  module Plan
    class NodeResult
      attr_reader :value

      def initialize(value = nil)
        @value = value
      end
    end
  end
end
