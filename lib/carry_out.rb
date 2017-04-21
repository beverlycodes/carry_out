require 'carry_out/version'

require 'carry_out/configurator'
require 'carry_out/configured_instance'
require 'carry_out/error'
require 'carry_out/result'
require 'carry_out/unit'

require 'carry_out/plan_builder'
require 'carry_out/plan_runner'

module CarryOut
  def self.call_unit(*args, &block)
    PlanRunner.call_unit(*args, &block)
  end

  def self.configuration
    @configuration ||= {}
  end

  def self.configure(&block)
    Configurator.new(configuration).instance_eval(&block)
  end

  def self.plan(options = {}, &block)
    merged_options = Hash.new.merge(configuration).merge(options)
    plan = PlanBuilder.build(merged_options, &block)

    Proc.new do |context = nil, &block| 
      PlanRunner.call(plan, context).tap do |result|
        block.call(result) unless block.nil?
      end
    end
  end

  def self.with_configuration(options = {})
    ConfiguredInstance.new(options)
  end
end
