module CarryOut
  class Error < StandardError
    attr_reader :details

    def initialize(message, details = nil)
      super message
      @details = details
    end
  end
end
