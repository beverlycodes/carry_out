# A Closure Is Not Always A Closure In Ruby - Alan Skorkin
# http://www.skorks.com/2013/03/a-closure-is-not-always-a-closure-in-ruby/

module CarryOut
  module Cloaker
    def cloaker(binding = nil, &b)
      meth = self.class.class_eval do
        define_method :cloaker_, &b
        meth = instance_method :cloaker_
        remove_method :cloaker_
        meth
      end
      
      with_previous_context(binding || b.binding) { meth.bind(self).call }
    end
   
    def with_previous_context(binding, &block)
      @previous_context = binding.eval('self')
      result = block.call
      @previous_context = nil
      result
    end
   
    def method_missing(method, *args, &block)
      if @previous_context
        @previous_context.send(method, *args, &block)
      else
        super
      end
    end
  end
end
