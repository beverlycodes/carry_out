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

    def execute(context = nil, &block)
      if @wrapper
        if @wrapper.respond_to?(:execute)
          @wrapper.execute do |wrapper_context|
            execute_internal(Result.new(context, wrapper_context), &block)
          end
        else
          @wrapper.call(Proc.new { |wrapper_context|
            execute_internal(Result.new(context, wrapper_context), &block)
          })
        end
      else
        execute_internal(Result.new(context), &block)
      end
    end

    def if(&block)
      raise NoMethodError("Conditional execution must be applied to a unit") unless @previously_added_node

      guards = node_meta(@previously_added_node)[:guards] ||= []
      guards << block

      self
    end

    def will(*args)
      self.then(*args)
    end

    def then(unit, options = {})
      add_node(PlanNode.new(unit), options[:as])
      self
    end

    def unless(&block)
      self.if { |refs| !block.call(refs) }
      
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

      def execute_internal(result = Result.new, &block)
        id = @initial_node_key

        until (node = @nodes[id]).nil? do
          execute_node(node, result) if guard_node(node, result.artifacts)
          break unless result.success?
          id = node.next
        end

        unless block.nil?
          block.call(result)
        end

        result
      end

      def execute_node(node, result)
        meta = node_meta(node)
        publish_to = meta[:as]

        begin
          node_result = node.execute(result.artifacts)
          result.add(publish_to, node_result) unless publish_to.nil?
        rescue UnitError => error
          result.add(publish_to || id, CarryOut::Error.new(error.error.message, error.error))
        end
      end

      def generate_node_name
        id = @next_node_id ||= 1
        @next_node_id += 1
        "node_#{id}".to_sym
      end

      def guard_node(node, artifacts)
        guards = node_meta(node)[:guards]
        guards.nil? || guards.map { |guard| guard.call(artifacts) }.all?
      end

      def node_meta(node)
        @node_meta[@nodes.key(node)]
      end
  end
end
