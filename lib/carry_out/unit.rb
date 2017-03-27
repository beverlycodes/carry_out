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
      unless var.nil?
        define_method(method_name.to_sym) do |*args|
          instance_variable_set("@#{var}", args.length == 0 ? true : args.first)
          self
        end
      end

      var = (var || method_name).to_s
      instance_var = "@#{var}"
  
      unless self.respond_to?(var)
        define_method(var) do |*args|
          if args.length > 0
            instance_variable_set(instance_var, args.first)
            return self
          end

          instance_variable_get(instance_var)
        end
      end

      unless self.respond_to?("#{var}=")
        define_method("#{var}=") do |value|
          instance_variable_set(instance_var, value)
        end
      end
    end
  end
end
