module CarryOut
  class PlanRunner
    def self.run(plan, context = {})
      PlanRunner.new.run(plan, context)
    end

    def run(plan, context = {})
      Result.new(context).tap do |plan_result|
        node = plan

        until node.nil?
          node_result = nil

          begin
            node_result = node.call(plan_result.artifacts)

            if node_result.kind_of?(Plan::NodeResult)
              plan_result.add(node.returns_as, node_result.value)
            end
          rescue StandardError => error
            error = CarryOut::Error.new(error.message, error) unless error.kind_of?(CarryOut::Error)
            plan_result.add node.returns_as, error 
          end

          break unless plan_result.success?
          node = node.connects_to
        end
      end
    end
  end
end
