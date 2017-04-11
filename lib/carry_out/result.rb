module CarryOut
  class Result

    def initialize(*args)
      @artifacts = args.compact.reduce(&:merge) || Hash.new
    end

    def add(group, object)
      if object.kind_of?(CarryOut::Error)
        add_error(group, object)
      elsif object.kind_of?(Result)
        add(group, object.to_hash)
        
        object.errors.each do |g, errors|
          errors.each { |e| add(g,e) }
        end
      elsif object.kind_of?(Hash)
        artifacts[group] ||= {}
        object.each { |k,v| artifacts[group][k] = v }
      elsif !artifacts[group].nil?
        artifacts[group] = [ artifacts[group], object ].flatten(1)
      else
        artifacts[group] = object
      end
    end

    def artifacts
      @artifacts ||= {}
    end

    def errors
      @errors ||= {}
    end

    def success?
      @errors.nil? || @errors.empty?
    end

    def to_hash
      artifacts
    end

    private
      def add_error(group, error)
        group = errors[group] ||= []
        group << error
      end
  end
end
