module CarryOut
  class Configurator
    def initialize(options)
      @options = options
    end

    def search(path)
      @options[:search] = [ path ].flatten(1)
    end
  end
end
