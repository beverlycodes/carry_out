module CarryOut
  class Result

    def add(group, label, object = nil)
      if label.kind_of?(CarryOut::Error)
        add_error(group, label)
      elsif !object.nil?
        group = artifacts[group] ||= {}
        group[label] = object
      else
        artifacts[group] = label
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

    private
      def add_error(group, error)
        group = errors[group] ||= []
        group << error
      end
  end
end
