local ComponentFlowSet = require "src.calc.ComponentFlowSet"
local Step = require "src.calc.Step"

local FixedStep = setmetatable({}, { __index = Step.meta })

function FixedStep:get_scaled_flow_set()
  return self.flow_set
end

function FixedStep:can_be_constrained_by()
  return false
end

function FixedStep:delete_invalid_constraints()
  return 0
end

local meta = { __index = FixedStep }

local function restore(self)
  ComponentFlowSet.restore(self.flow_set)
  return setmetatable(self, meta)
end

local function new(component, rate)
  local flow_set = ComponentFlowSet.new()
  flow_set:add(component, rate)
  local self = {
    type = "fixed",
    flow_set = flow_set,
  }
  return restore(self)
end

Step.subclass_restore["fixed"] = restore

return {
  new = new,
  restore = restore,
}