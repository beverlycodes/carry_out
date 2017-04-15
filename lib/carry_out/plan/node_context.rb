require "carry_out/cloaker"

module CarryOut
  module Plan
    class NodeContext
      include CarryOut::Cloaker

      def initialize(node)
        @node = node
      end

      def action
        self
      end

      def context(*args)
        Proc.new do |context|
          args.inject(context) { |c, k| c.nil? ? nil : c[k] }
        end
      end

      def only_when(value = nil, &block)
        @node.guard_with(value || block)
      end

      def except_when(value = nil, &block)
        @node.guard_with_inverse(value || block)
      end

      def method_missing(method, *args, &block)
        if @node.respond_to?(method)
          @node.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to?(method)
        @node.respond_to?(method)
      end

      def return_as(key, &block)
        @node.returns_as = key
        @node.return_transform = block unless block.nil?
      end
    end
  end
end
