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

            if node_result.kind_of?(Plan::NodeResult) && node.returns_as
              plan_result.add(node.returns_as, node_result.value)

              if node_result.value.kind_of?(CarryOut::Result) && !node_result.value.success?
                break
              end
            end

            node = node.connects_to
          rescue StandardError => error
            plan_result.add (node.returns_as || :base), CarryOut::Error.new(error.message, error)
            break
          end
        end
      end
    end
  end
end
