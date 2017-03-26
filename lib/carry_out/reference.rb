module CarryOut
  class Reference

    def initialize(*args)
      @key_path = args
    end

    def call(context)
      result = context
      @key_path.each do |key|
        if context.respond_to?(:has_key?) && context.has_key?(key)
          result = context[key]
        else
          result = nil
          break
        end
      end

      result
    end
  end
end
