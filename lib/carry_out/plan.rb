module CarryOut
  class Plan
    
    def initialize(unit = nil, options = {})
      @nodes = {}
      @previously_added_node = nil
      @initial_node_key = add_node(PlanNode.new)

      unless unit.nil?
        self.then(unit, options)
      end
    end

    def execute(&block)
      node = @nodes[@initial_node_key]
      label = node.next unless node.nil?

      Result.new.tap do |result|
        while node = @nodes[label] do
          begin
            node.execute(ResultManipulator.new(result, label), result.artifacts)
          rescue UnitError => error
            result.add(label, CarryOut::Error.new(error.error.message, error.error))
            break
          end

          label = node.next
        end

        unless block.nil?
          block.call(result)
        end
      end
    end

    def then(unit, options = {})
      add_node(PlanNode.new(unit), options[:as])
      self
    end

    def method_missing(method, *args, &block)
      if @previously_added_node
        @previously_added_node.send(method, *args, &block)
        self
      else
        super
      end
    end

    def respond_to?(method)
      (@previously_added_node && @previously_added_node.respond_to?(method)) || super
    end

    private
      def add_node(node, as = nil)
        label = (as || generate_node_name)

        if as.nil?
          until @nodes[label].nil?
            label = generate_node_name
          end
        end

        unless @previously_added_node.nil?
          @previously_added_node.next = label
        end

        @nodes[label] = node
        @previously_added_node = node

        label
      end

      def generate_node_name
        id = @next_node_id ||= 1
        @next_node_id += 1
        "node_#{id}".to_sym
      end
  end
end
