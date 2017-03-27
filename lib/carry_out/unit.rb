module CarryOut
  class Unit
    
    def execute
    end

    def self.appending_parameter(method_name, var)
      instance_var = "@#{var}"

      define_method(method_name.to_sym) do |value|
        existing = 
          if instance_variable_defined?(instance_var)
            [ instance_variable_get("@#{var}") ].flatten(1)
          else
            []
          end
        
        instance_variable_set(instance_var, (existing || []) << value)
        self
      end
    end

    def self.parameter(method_name, var = nil)
      var ||= method_name

      define_method(method_name.to_sym) do |*args|
        instance_variable_set("@#{var}", args.length == 0 ? true : args.first)
        self
      end
    end
  end
end
