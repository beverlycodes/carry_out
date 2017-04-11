module CarryOut
  module Plan
    class NodeContext
      def initialize(node)
        @node = node
      end

      def action
        self
      end

      def context(*args)
        -> (context) do
          args.inject(context) { |c, k| c.nil? ? nil : c[k] }
        end
      end

      def only_when(value = nil, &block)
        @node.guard_with (value || block)
      end

      def except_when(value = nil, &block)
        @node.guard_with_inverse (value || block)
      end

      def method_missing(method, *args, &block)
        @node.send(method, *args, &block)
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
