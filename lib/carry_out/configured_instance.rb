module CarryOut
  class ConfiguredInstance
    def initialize(options = {})
      @options = Hash.new
      @options[:search] = options[:search] if options.has_key?(:search)
    end

    def plan(options = {}, &block)
      CarryOut.plan(Hash.new.merge(@options).merge(options), &block) 
    end

    def call_unit(*args, &block)
      CarryOut.call_unit(*args)
    end
  end
end
