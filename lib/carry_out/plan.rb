module CarryOut
  class Plan
    
    def initialize(unit = nil, options = {})
      @nodes = {}
      @node_meta = {}
      @previously_added_node = nil
      @wrapper = options[:within]

      unless unit.nil?
        self.then(unit, options)
      end
    end

    def execute(&block)
      if @wrapper
        if @wrapper.respond_to?(:execute)
          @wrapper.execute do |context|
            execute_internal(Result.new(context), &block)
          end
        else
          @wrapper.call(Proc.new do |context|
            execute_internal(Result.new(context), &block)
          end)
        end
      else
        execute_internal(&block)
      end
    end

    def will(*args)
      self.then(*args)
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
        id = generate_node_name

        if @previously_added_node.nil?
          @initial_node_key = id
        else
          @previously_added_node.next = id
        end

        @nodes[id] = node
        @node_meta[id] = { as: as }
        @previously_added_node = node

        id
      end

      def execute_internal(result = nil, &block)
        id = @initial_node_key

        (result || Result.new).tap do |result|
          while node = @nodes[id] do
            publish_to = @node_meta[id][:as]

            begin
              node_result = node.execute(result.artifacts)
              result.add(publish_to, node_result) unless publish_to.nil?
            rescue UnitError => error
              result.add(publish_to || id, CarryOut::Error.new(error.error.message, error.error))
              break
            end

            id = node.next
          end

          unless block.nil?
            block.call(result)
          end
        end
      end

      def generate_node_name
        id = @next_node_id ||= 1
        @next_node_id += 1
        "node_#{id}".to_sym
      end
  end
end
