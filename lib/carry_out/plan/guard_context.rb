module CarryOut
  module Plan
    class GuardContext
      def initialize(context = {})
        @context = context
      end

      def context(*args)
        args.inject(@context) { |c, k| c.nil? ? nil : c[k] }
      end
    end
  end
end
