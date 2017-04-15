require "carry_out/plan/node"
require "carry_out/plan/node_context"

module CarryOut
  class PlanBuilder
    include Cloaker

    attr_reader :plan

    def initialize(options = {}, &block)
      @plan = Plan::Node.new
      @constant_resolver = [ options[:search] ].flatten(1)
      @block_binding = options[:block_binding]

      configure_node(@plan, &block) if block
    end

    def self.build(options = {}, &block)
      options = {
        block_binding: block.binding
      }.merge(options)

      builder = PlanBuilder.new(options)

      builder.cloaker(&block)
      builder.plan
    end

    def call(unit = nil, &block)
      unit = find_object(unit) if unit.is_a?(Symbol) || unit.is_a?(String)
      node = Plan::Node.new(unit)

      configure_node(node, &block) if block
      current_node.connects_to = node
      self.current_node = node

      node
    end

    alias_method :then_call, :call

    def method_missing(method, *args, &block)
      obj = find_object(method)

      if obj
        call(obj, &block)
      else
        super
      end
    end

    private
      attr_writer :current_node

      def configure_node(node, &block)
        Plan::NodeContext.new(node).cloaker(@block_binding, &block)
      end

      def current_node
        @current_node ||= @plan
      end

      def find_object(name)
        constant_name = name.to_s.split('_').map { |w| w.capitalize }.join('')

        @constant_resolver.inject(nil) do |obj, m|
          return obj if obj

          if m.respond_to?(:call)
            m.call(constant_name)
          else
            m.const_get(constant_name) rescue nil
          end
        end
      end
  end
end
