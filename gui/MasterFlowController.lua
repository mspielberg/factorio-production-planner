local mod_gui = require "mod-gui"
local PlannerFrameController = require "gui.PlannerFrameController"

local MasterFlowController = {}

function MasterFlowController:on_show_hide_button()
  self.planner_frame:toggle_show_hide()
end

local M = {}
local meta = { __index = MasterFlowController }

function M.new(view)
  local self = {
    view = view,
    planner_frame = PlannerFrameController.new(view.planner_frame),
  }
  view:set_controller(self)

  M.restore(self)
  return self
end

function M.restore(self)
  setmetatable(self, meta)
  PlannerFrameController.restore(self.planner_frame)
  return self
end

return M
