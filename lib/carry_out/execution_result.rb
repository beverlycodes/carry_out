module CarryOut
  class ExecutionResult
    DISPOSITIONS = [ :pass, :fail, :skip ]
    DISPOSITION_TYPE_ERROR = "Disposition must be one of %{dispositions}"

    attr_reader :disposition
    attr_reader :artifact

    def initialize(disposition, options = {})
      raise ArgumentError.new(DISPOSITION_TYPE_ERROR % DISPOSITIONS.map { |d| ":#{d.to_sym}"}) unless DISPOSITIONS.include?(disposition)

      @disposition = disposition
      @artifact = options[:artifact]
    end
  end
end
