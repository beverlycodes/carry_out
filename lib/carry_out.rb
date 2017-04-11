require 'carry_out/version'

require 'carry_out/configurator'
require 'carry_out/error'
require 'carry_out/result'
require 'carry_out/unit'

require 'carry_out/plan_builder'
require 'carry_out/plan_runner'

module CarryOut
  class ConfiguredInstance
    def initialize(options = {})
      @options = Hash.new
      @options[:search] = options[:search] if options.has_key?(:search)
    end

    def plan(options = {}, &block)
      CarryOut.plan(Hash.new.merge(@options).merge(options), &block) 
    end
  end

  def self.configure(&block)
    Configurator.new(configuration).instance_eval(&block)
  end

  def self.plan(options = {}, &block)
    merged_options = Hash.new.merge(configuration).merge(options)
    plan = PlanBuilder.build(merged_options, &block)
    -> (context = nil) { PlanRunner.run(plan, context) }
  end

  def self.configuration
    @configuration ||= {}
  end

  def self.with_configuration(options = {})
    ConfiguredInstance.new(options)
  end
end
