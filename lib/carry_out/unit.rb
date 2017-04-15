module CarryOut
  class Unit
    
    def call
      raise "Expected #{self.class} to define #{self.class}#call" unless self.class == Unit
    end

    def initialize
      self.class.parameter_defaults.each do |p, d|
        instance_variable_set("@#{p}", d)
      end
    end

    def self.call(&block)
      unit = self.new
      yield unit if block
      unit.call
    end

    def self.has_parameter?(method)
      self.instance_methods.include?(method)
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

    def self.parameter(method_name, var = nil, options = {})
      if var.kind_of?(Hash)
        options = var 
        var = nil
      end

      var ||= method_name

      define_method(method_name.to_sym) do |*args|
        instance_variable_set("@#{var}", args.length == 0 ? true : args.first)
        self
      end

      parameter_defaults[var] = options[:default] unless options[:default].nil?
    end

    def self.parameter_defaults
      @parameter_defaults ||= {}
    end
  end
end
