require "carry_out/version"

require "carry_out/error"
require "carry_out/plan"
require "carry_out/plan_node"
require "carry_out/reference"
require "carry_out/result"
require "carry_out/unit"
require "carry_out/unit_error"

module CarryOut
  MATCH_CONTINUATION_METHOD = /^will_/
  MATCH_WITHIN_METHOD = /^within_/

  class ConfiguredCarryOut
    def initialize(options = {})
      @config = options
    end

    def get(*args)
      Reference.new(*args)
    end

    def method_missing(method, *args, &block)
      if MATCH_CONTINUATION_METHOD =~ method
        create_plan.send(method, *args, &block)
      elsif MATCH_WITHIN_METHOD =~ method
        create_plan.send(method, *args, &block)
      else
        super
      end
    end

    def will(*args)
      create_plan.will(*args)
    end

    def within(wrapper = nil, &block)
      create_plan(within: wrapper || block)
    end

    private
      def create_plan(options = {})
        Plan.new(nil, @config.merge(options))
      end
  end

  def self.configured_with(options = {})
    ConfiguredCarryOut.new(options)
  end

  def self.defaults=(options = {})
    @default_options = options
    @default_carry_out = nil
  end

  def self.method_missing(method, *args, &block)
    default_carry_out.send(method, *args, &block)
  end

  private
    def self.default_options
      @default_options ||= Hash.new
    end

    def self.default_carry_out
      @default_carry_out ||= ConfiguredCarryOut.new(default_options)
    end
end
