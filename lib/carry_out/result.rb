require 'carry_out/result_error'

module CarryOut
  class Result

    def initialize(*args)
      @artifacts = args.compact.reduce(&:merge) || Hash.new
    end

    def add(group, object)
      if object.kind_of?(CarryOut::Error)
        errors << ResultError.new(
          group: group,
          message: object.message,
          details: object.details
        )
      elsif object.kind_of?(Enumerable) && object.all? { |o| o.kind_of?(CarryOut::Error) }
        object.each { |o| add(group, o) }
      elsif object.kind_of?(Result)
        add(group, object.to_hash)
        
        object.errors.each do |error|
          add([group, error.group].flatten(1), e)
        end
      elsif object.kind_of?(Hash)
        artifacts[group] ||= {}
        object.each { |k,v| artifacts[group][k] = v }
      elsif !artifacts[group].nil?
        artifacts[group] = [ artifacts[group], object ].flatten(1)
      else
        artifacts[group] = object
      end
    end

    def artifacts
      @artifacts ||= {}
    end

    def errors
      @errors ||= []
    end

    def success?
      @errors.nil? || @errors.empty?
    end

    def to_hash
      artifacts
    end
  end
end
