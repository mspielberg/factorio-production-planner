local ProductionLineFlow = require "gui.ProductionLineFlow"

local function add_frame(self, parent)
  local frame = parent.add{
    name = "planner_frame",
    type = "frame",
    direction = "vertical",
    caption = {"planner-gui.planner-frame-caption"},
  }
  self.gui = frame
  self.production_line_flow = ProductionLineFlow.new(self.gui)
end

local PlannerFrame = {}

local M = {}
local meta = { __index = PlannerFrame }

function M.new(parent)
  local self = {
    gui = nil,
    production_line_flow = nil,
  }
  add_frame(self, parent)
  return M.restore(self)
end

function M.restore(self)
  ProductionLineFlow.restore(self.production_line_flow)
  return setmetatable(self, meta)
end

return M