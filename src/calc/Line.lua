local ComponentFlowSet = require "src.calc.ComponentFlowSet"
local Step = require "src.calc.Step"

---@class Line
local Line = {}

---@return ComponentFlowSet
function Line:get_scaled_flow_set()
  local flow_sets = {}
  for _, step in pairs(self.steps) do
    if step.type ~= "fixed" then
      flow_sets[#flow_sets+1] = step:get_scaled_flow_set(self)
    end
  end
  return ComponentFlowSet.sum(flow_sets)
end

function Line:delete_invalid_constraints()
  for _, step in pairs(self.steps) do
    step:delete_invalid_constraints()
  end
end

function Line:get_step_by_id(step_id)
  for _, step in pairs(self.steps) do
    if step.id == step_id then
      return step
    end
  end
  return nil
end

---@param planner Planner
function Line:attach_planner(planner)
  self.id = planner:get_next_line_id()
  for _, step in pairs(self.steps) do
    if step.type == "line" then
      step.planner = planner
    end
  end
end

function Line:add_step(step)
  step.id = self.next_step_id
  self.next_step_id = self.next_step_id + 1
  self.steps[#self.steps+1] = step
end

function Line:reorder_step(step_index, new_index)
  local step = self.steps[step_index]
  if not step then error("invalid step index "..step_index) end
  if new_index < 0 or new_index > #self.steps then error("invalid new_index "..new_index) end
  table.remove(self.steps, step_index)
  table.insert(self.steps, new_index, step)
end

function Line:delete_step(step_id)
  for i, step in pairs(self.steps) do
    if step.id == step_id then
      self.steps[i] = nil
      break
    end
  end
  self:delete_invalid_constraints()
end

local meta = { __index = Line }

--- @return Line
local function restore(self)
  for _, step in pairs(self.steps) do
    Step.restore(step)
  end
  return setmetatable(self, meta)
end

--- @return Line
local function new()
  local self = {
    name = "",
    steps = {},

    next_step_id = 1,
  }
  return restore(self)
end

return {
  new = new,
  restore = restore,
}