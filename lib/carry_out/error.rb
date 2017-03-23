module CarryOut
  class Error
    attr_reader :details
    attr_reader :message

    def initialize(message, details = nil)
      @message = message
      @details = details
    end
  end
end
