module CarryOut
  class UnitError < StandardError
    attr_reader :error

    def initialize(error)
      @error = error
    end
  end
end
