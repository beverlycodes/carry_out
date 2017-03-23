module CarryOut
  class ResultManipulator
    
    def initialize(result, group)
      @result = result
      @group = group
    end

    def add(label, object = nil)
      @result.add(@group, label, object) unless @group.nil?
    end
  end
end
