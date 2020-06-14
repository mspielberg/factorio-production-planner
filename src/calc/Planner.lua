local FixedStep = require "src.calc.FixedStep"
local Line = require "src.calc.Line"
local LineStep = require "src.calc.LineStep"
local RecipeStep = require "src.calc.RecipeStep"

---@class Planner
local Planner = {}

function Planner:get_next_line_id()
  local id = self.next_line_id
  self.next_line_id = id + 1
  return id
end

function Planner:get_line_by_id(line_id)
  return self.lines[line_id]
end

function Planner:add_line(line)
  line:attach_planner(self)
  self.lines[#self.lines+1] = line
end

local meta = { __index = Planner }

local function restore(self)
  return setmetatable(self, meta)
end

local function new()
  local self = {
    lines = {},

    next_line_id = 1,
  }
  return restore(self)
end

return {
  new = new,
}