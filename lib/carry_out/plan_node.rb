module CarryOut
  class PlanNode
    attr_reader :next

    def initialize(klass = nil)
      @unitClass = klass
      @messages = []
    end

    def method_missing(method, *args, &block)
      if is_parameter_method?(*args, &block)
        append_message(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method)
      if @unitClass.respond_to?(:instance_methods)
        @unitClass.instance_methods.include?(method) || super
      else
        @unitClass.respond_to?(method) || super
      end
    end

    def execute(context)
      unit = is_callable?(@unitClass) ? @unitClass : @unitClass.new

      @messages.each do |message|
        arg =
          if message[:block]
            Context.new(context).instance_exec(context, &message[:block])
          else
            message[:argument]
          end

        unit.send(message[:method], arg)
      end

      begin
        unit.respond_to?(:execute) ? unit.execute : unit.call(context)
      rescue StandardError => error
        raise UnitError.new(error)
      end
    end

    def next=(value)
      @next = value.to_sym
    end

    private
      def append_message(method, *args, &block)
        if !args.first.nil? && !block.nil?
          raise ArgumentError.new("Arguments, references, and blocks are mutually exclusive")
        end

        if @unitClass.instance_methods.include?(method)
          if args.first.kind_of?(Reference)
            @messages << { method: method, block: -> (refs) { args.first.call(refs) } }
          else
            @messages << { method: method, argument: args.first || true, block: block }
          end
        else
          raise NoMethodError.new("#{@unitClass} instances do not respond to `#{method}'", method, *args)
        end
      end

      def is_callable?(obj)
        obj.respond_to?(:execute) || obj.respond_to?(:call)
      end
      
      def is_parameter_method?(*args, &block)
        args.length <= 1 || (args.length == 0 && !block.nil?)
      end
  end
end
