local Step = require "src.calc.Step"

---@class LineStep : Step
local LineStep = setmetatable({}, { __index = Step.meta })

function LineStep:get_base_flow_set()
  local line = self.planner:get_line_by_id(self.line_id)
  return line:get_scaled_flow_set()
end

local meta = { __index = LineStep }

local function restore(self)
  return setmetatable(self, meta)
end

local function new(planner, line_id)
  local self = {
    type = "line",
    planner = planner,
    line_id = line_id,
  }
  return restore(self)
end

Step.subclass_restore["line"] = restore

return {
  new = new,
  restore = restore,
}
