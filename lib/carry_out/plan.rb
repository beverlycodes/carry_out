module CarryOut
  class Plan
    MATCH_CONTINUATION_METHOD = /^(?:will|then)_(.+)/
    MATCH_CONTEXT_METHOD = /^within_(.+)/
    MATCH_RETURNING_METHOD = /^returning_as_(.+)/

    def initialize(unit = nil, options = {})
      @nodes = {}
      @node_meta = {}
      @previously_added_node = nil
      @wrapper = options[:within]
      @search = options[:search] || []

      self.then(unit, options) unless unit.nil?
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

    def if(reference = nil, &block)
      raise NoMethodError("Conditional execution must be applied to a unit") unless @previously_added_node

      guards = node_meta(@previously_added_node)[:guards] ||= []
      guards << (reference || block)

      self
    end

    def will(*args)
      self.then(*args)
    end

    def then(unit = nil, options = {})
      add_node(PlanNode.new(unit), options[:as]) unless unit.nil?
      self
    end

    def unless(reference = nil, &block)
      self.if { |refs| !(reference || block).call(refs) }
      
      self
    end

    def method_missing(method, *args, &block)
      if MATCH_CONTINUATION_METHOD =~ method
        obj = find_object($1)
        return super if obj.nil?
        self.then(obj, *args, &block)
      elsif MATCH_CONTEXT_METHOD =~ method
        obj = find_object($1)
        return super if obj.nil?
        @wrapper = obj.new
        self
      elsif @previously_added_node
        if MATCH_RETURNING_METHOD =~ method
          node_meta(@previously_added_node)[:as] = $1.to_sym
        else
          @previously_added_node.send(method, *args, &block)
        end
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
          result.add(publish_to || key_for_node(node), CarryOut::Error.new(error.error.message, error.error))
        end
      end

      def find_object(name)
        constant_name = name.to_s.split('_').map { |w| w.capitalize }.join('')

        if @search.respond_to?(:call)
          @search.call(constant_name)
        else
          containing_module = @search.find { |m| m.const_get(constant_name) rescue nil }
          containing_module.const_get(constant_name) unless containing_module.nil?
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

      def key_for_node(node)
        @nodes.key(node)
      end

      def node_meta(node)
        @node_meta[key_for_node(node)]
      end
  end
end
