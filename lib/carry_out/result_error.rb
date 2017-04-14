module CarryOut
  class ResultError
    attr_reader :details
    attr_reader :message

    def initialize(options = {})
      @details = options[:details]
      @message = options[:message]
    end
  end
end
