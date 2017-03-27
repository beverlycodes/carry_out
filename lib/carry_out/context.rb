module CarryOut
  class Context
    MATCH_RESULT_METHOD = /^result_of_(.+)/

    def initialize(context)
      @context = context
    end

    def method_missing(method, *args, &block)
      if MATCH_RESULT_METHOD =~ method && args.empty? && block.nil?
        @context[$1.to_sym]
      else
        super
      end
    end
  end
end
