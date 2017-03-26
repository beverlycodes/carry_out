require "carry_out/version"

require "carry_out/error"
require "carry_out/plan"
require "carry_out/plan_node"
require "carry_out/reference"
require "carry_out/result"
require "carry_out/unit"
require "carry_out/unit_error"

module CarryOut
  def self.get(*args)
    Reference.new(*args)
  end

  def self.will(*args)
    Plan.new(*args)
  end

  def self.within(unit = nil, &block)
    Plan.new(nil, within: unit || block)
  end
end
