module CarryOut
  class Result

    def add(group, label, object = nil)
      if label.kind_of?(CarryOut::Error)
        add_error(group, label)
      else
        group = artifacts[group] ||= {}
        group[label] = object
      end
    end

    def artifacts
      @artifacts ||= {}
    end

    def errors
      @errors ||= {}
    end

    private
      def add_error(group, error)
        group = errors[group] ||= []
        group << error
      end
  end
end
