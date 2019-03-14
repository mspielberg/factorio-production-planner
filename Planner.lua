local CraftingMachineLibrary = require "CraftingMachineLibrary"
local ProductionLine = require "ProductionLine"

local Planner = {}

local M = {}
local meta = { __index = Planner }

function M.new()
  local self = {
    current_line = nil,
    production_lines = {},
    crafting_machine_library = CraftingMachineLibrary.new(),
  }
  self.production_lines[1] = ProductionLine.new(self)
  self.current_line = self.production_lines[1]
  return M.restore(self)
end

function M.instance(player_index)
  if not global.planners then
    global.planners = {}
  end
  local planner = global.planners[player_index]
  if not planner then
    planner = M.new()
    global.planners[player_index] = planner
  end
  return planner
end

function M.restore(self)
  for _, line in ipairs(self.production_lines) do
    ProductionLine.restore(line)
  end
  CraftingMachineLibrary.restore(self.crafting_machine_library)
  return setmetatable(self, meta)
end

return M
