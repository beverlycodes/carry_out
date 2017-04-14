require 'carry_out/result_error'

module CarryOut
  class Result

    def initialize(*args)
      @artifacts = args.compact.reduce(&:merge) || Hash.new
    end

    def add(group, object)
      if object.kind_of?(CarryOut::Error)
        object = ResultError.new(
          message: object.message,
          details: object.details
        )
      end

      if object.kind_of?(CarryOut::ResultError)
        group = group || :_unlabeled
        errors[group] ||= []
        errors[group] << object
      elsif object.kind_of?(Enumerable) && object.all? { |o| o.kind_of?(CarryOut::Error) }
        object.each { |o| add(group, o) }
      else
        unless group.nil?
          if object.kind_of?(Hash)
            artifacts[group] ||= {}
            object.each { |k,v| artifacts[group][k] = v }
          elsif object.kind_of?(Result)
            add(group, object.artifacts)

            object.errors.each do |g, errors|
              error_group = [ group, g ]

              errors.each { |e| add(error_group, e) }
            end
          else
            artifacts[group] = object
          end
        end
      end
    end

    def artifacts
      @artifacts ||= {}
    end

    def errors
      @errors ||= {}
    end

    def success?
      @errors.nil? || @errors.empty?
    end
  end
end
