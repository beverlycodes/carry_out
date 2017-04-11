require "carry_out/plan/node"
require "carry_out/plan/node_context"

module CarryOut
  class PlanBuilder
    def initialize(options = {}, &block)
      @plan = Plan::Node.new
      @wrapper = nil
      @constant_resolver = [ options[:search] ].flatten(1)

      configure_node(@plan, &block) if block
    end

    attr_reader :plan

    def self.build(options = {}, &block)
      builder = PlanBuilder.new(options)
      builder.instance_eval(&block)
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
        call(method, &block)
      else
        super
      end
    end

    private
      attr_writer :current_node

      def configure_node(node, &block)
        Plan::NodeContext.new(node).instance_eval(&block)
      end

      def current_node
        @current_node ||= @plan
      end

      def find_object(name)
        constant_name = name.to_s.split('_').map { |w| w.capitalize }.join('')

        @constant_resolver.inject(nil) do |obj, m|
          return obj if obj

          if m.respond_to?(:call)
            obj = m.call(constant_name)
          else
            obj = m.const_get(constant_name) rescue nil
          end
        end
      end
  end
end
