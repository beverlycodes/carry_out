require "carry_out/plan/guard"
require "carry_out/plan/node_result"

module CarryOut
  module Plan
    class Node
      attr_accessor :action
      attr_accessor :connects_to
      attr_reader :guarded_by
      attr_accessor :returns_as
      attr_accessor :return_transform

      def initialize(action = nil)
        @action = action
        @messages = []
      end

      def call(context = {})
        return NodeResult.new unless @action
        return unless guard(context)

        result = @action.call do |a|
          @messages.map do |m|
            value = m[:source]
            
            if value.respond_to?(:call)
              value = GuardContext.new(context).instance_exec(context, &value)
            end

            a.send(m[:method], value)
          end
        end
        
        result = return_transform.call(result) unless return_transform.nil?

        NodeResult.new(result)
      end

      def guard_with(guard)
        guard = guard.respond_to?(:call) ? guard : Proc.new { guard }
        guarded_by.push Guard.new(guard)
      end

      def guard_with_inverse(guard)
        guard_with(guard)
        guarded_by.last.invert
      end

      def guarded_by
        @guarded_by ||= []
      end

      def method_missing(method, *args, &block)
        if respond_to?(method)
          @messages.push({ method: method, source: block || (args.length == 0 ? true : args.first) })
        end
      end

      def respond_to?(method, private = false)
        (@action && @action.respond_to?(:has_parameter?) && @action.has_parameter?(method)) || super
      end

      private
        def guard(context = {})
          guarded_by.empty? || guarded_by.all? { |g| g.call(context) }
        end
    end
  end
end
