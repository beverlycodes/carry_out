module CarryOut
  class ResultError
    attr_reader :details
    attr_reader :group
    attr_reader :message

    def initialize(options = {})
      @details = options[:details]
      @group = options[:group]
      @message = options[:message]
    end
  end
end
