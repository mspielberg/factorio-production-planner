local CraftingMachine = require "CraftingMachine"
local inspect = require "inspect"
local ProductionLine = require "ProductionLine"

local Planner = {}

local M = {}
local meta = { __index = Planner }

function M.new()
  local self = {
    current_line = nil,
    production_lines = {},
    default_crafting_machines = CraftingMachine.default_crafting_machines(),
  }
  self.production_lines[1] = ProductionLine.new(self)
  self.current_line = self.production_lines[1]
  return M.restore(self)
end

function M.restore(self)
  for _, line in ipairs(self.production_lines) do
    ProductionLine.restore(line)
  end
  for _, cm in pairs(self.default_crafting_machines) do
    CraftingMachine.restore(cm)
  end
  return setmetatable(self, meta)
end

return M
