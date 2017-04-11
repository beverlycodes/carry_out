module CarryOut
  DEFAULT_ACTION = -> (context) { }

  def initialize(action = nil)
    @action = action unless action.nil?
  end

  def call(context)
    args = []
    args << context if @action.method(:call).arity > 0

    begin
      ExecutionResult.new :pass, artifact: @action.send(:call, *args)
    rescue StandardError => error
      ExecutionResult.new :fail
    end
  end

  private
    def action
      @action ||= DEFAULT_ACTION
    end
end
