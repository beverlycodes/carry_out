module CarryOut
  class PlanRunner
    def self.call(plan, context = {})
      Result.new(context).tap do |plan_result|
        node = plan

        until node.nil?
          node_result = nil

          begin
            node_result = node.call(plan_result.artifacts)

            if node_result.kind_of?(Plan::NodeResult)
              plan_result.add(node.returns_as, node_result.value)
            end
          rescue CarryOut::Error => error
            plan_result.add node.returns_as, error 
          end

          break unless plan_result.success?
          node = node.connects_to
        end
      end
    end

    def self.call_unit(unit, context = {}, &block)
      node = Plan::Node.new(unit)
      Plan::NodeContext.new(node).cloaker(&block) unless block.nil?

      call(node, context)
    end
  end
end
