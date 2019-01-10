local ProductionLine = require "ProductionLine"

local Planner = {}

local M = {}
local meta = { __index = Planner }

function M.new()
  local self = {
    current_line = nil,
    production_lines = { ProductionLine.new() }
  }
  self.current_line = self.production_lines[1]
  return M.restore(self)
end

function M.restore(self)
  for _, line in ipairs(self.production_lines) do
    ProductionLine.restore(line)
  end
  return setmetatable(self, meta)
end

return M
