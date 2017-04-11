require 'carry_out/plan/guard_context'

module CarryOut
  module Plan
    class Guard
      def initialize(proc, options = {})
        @proc = proc
        invert(options[:invert])
      end

      def call(context = {})
        result = GuardContext.new(context).instance_exec(context, &@proc)
        result = !result if @invert
        result
      end

      def invert(is_inverted = true)
        @invert = !!is_inverted
      end
    end
  end
end
