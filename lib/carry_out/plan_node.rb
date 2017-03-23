module CarryOut
  class PlanNode
    attr_reader :next

    def initialize(klass = nil)
      @unitClass = klass
      @messages = []
    end

    def method_missing(method, *args, &block)
      if args.length == 1 || (args.length == 0 && !block.nil?)
        if @unitClass.instance_methods.include?(method)
          @messages << { method: method, argument: args.first, block: block }
        else
          raise NoMethodError.new("#{@unitClass} instances do not respond to `#{method}'", method, *args)
        end
      else
        super
      end
    end

    def raises?(klass)
      @unitClass.raises?(klass)
    end

    def respond_to?(method)
      @unitClass.instance_methods.include?(method) || super
    end

    def execute(result, artifacts)
      unit = @unitClass.new

      @messages.each do |message|
        arg = message[:block] ? message[:block].call(artifacts) : message[:argument]
        unit.send(message[:method], arg)
      end

      begin
        unit.execute(result)
      rescue StandardError => error
        raise UnitError.new(error)
      end
    end

    def next=(value)
      @next = value.to_sym
    end
  end
end
