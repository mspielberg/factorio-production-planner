local ComponentFlowSet = require "src.calc.ComponentFlowSet"
local serpent = require "serpent"
local util = require "src.util"

-- @treturn {[number]=ComponentFlowSet,...}
local function get_constraining_step_flow_sets(self, line)
  local out = {}
  for _, step_ids in pairs(self.constraints) do
    for _, step_id in pairs(step_ids) do
      if not out[step_id] then
        out[step_id] = line:get_step_by_id(step_id):get_scaled_flow_set(line)
      end
    end
  end
  return out
end

-- @treturn ComponentFlowSet
local function get_constraint_flow_set(self, line)
  local out = ComponentFlowSet.new()
  local flow_sets = get_constraining_step_flow_sets(self, line)
  for component, step_ids in pairs(self.constraints) do
    for _, step_id in pairs(step_ids) do
      local other_rate = -flow_sets[step_id]:get_rate(component)
      out:add(component, other_rate)
    end
  end
  return out
end

---@class Step
local Step = {}

function Step:get_rate(line)
  local base_flow_set = self:get_base_flow_set()
  local constraint_flow_set = get_constraint_flow_set(self, line)
  local new_rate = 0
  for component, required_rate in pairs(constraint_flow_set) do
    local required_step_rate = required_rate / base_flow_set[component]
    if required_step_rate > new_rate then
      new_rate = required_step_rate
    end
  end
  return new_rate
end

-- @tparam Step other
-- @tparam Component component
-- @treturn bool
function Step:can_be_constrained_by(other, component)
  local my_count = self:get_base_flow_set()[component]
  local other_count = other:get_base_flow_set()[component]
  return my_count and other_count and my_count * other_count < 0 or false
end

-- @param line Line
-- @return ComponentFlowSet
function Step:get_base_flow_set(line)
  error("Step:get_base_flow_set should never be called")
end

function Step:get_scaled_flow_set(line)
  return self:get_base_flow_set(self):scale(self:get_rate(line))
end

function Step:add_constraint(constraining_step_id, component)
  local constraints = self.constraints
  constraints[component] = constraints[component] or {}
  table.insert(constraints[component], constraining_step_id)
end

function Step:delete_constraint(constraining_step_id, component)
  local step_ids = self.constraints[component]
  if not step_ids then return self end
  local k = util.find(step_ids, constraining_step_id)
  if not k then return self end

  table.remove(step_ids, k)
  if next(step_ids) then
    table.sort(step_ids)
  else
    self.constraints[component] = nil
  end
end

-- @treturn number Count of invalid constraints deleted.
function Step:delete_invalid_constraints(line)
  local to_delete = {}
  for component, step_ids in pairs(self.constraints) do
    for _, step_id in pairs(step_ids) do
      local other = line:get_step_by_id(step_id)
      if not other or not self:can_be_constrained_by(other, component) then
        to_delete[#to_delete+1] = {step_id, component}
      end
    end
  end
  for _, v in pairs(to_delete) do
    self:delete_constraint(to_delete[1], to_delete[2])
  end
  return #to_delete
end

local subclass_restore = {}

local function restore(self)
  if subclass_restore[self.type] then
    subclass_restore[self.type](self)
  else
    subclass_restore.default(self)
  end
end

return {
  restore = restore,
  meta = Step,
  subclass_restore = subclass_restore,
}