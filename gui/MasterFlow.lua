local Dispatcher = require "gui.Dispatcher"
local PlannerFrame = require "gui.PlannerFrame"
local RecipePickerFrame = require "gui.RecipePickerFrame"

local function create_show_hide_button(player)
  return mod_gui.get_button_flow(player).add{
    name = "planner_show_hide_button",
    type = "button",
    caption = "Show Planner",
  }
end

local function create_flow(player)
  return mod_gui.get_frame_flow(player).add{
    name = "planner",
    type = "flow",
    direction = "horizontal",
  }
end

local function register_event_handlers(self)
  Dispatcher.register(
    defines.events.on_gui_click,
    self.show_hide_button,
    function(event)
      self.controller:on_show_hide_button(self)
    end)
end

local MasterFlowView = {}

function MasterFlowView:set_controller(controller)
  self.controller = controller
end

local M = {}

local meta = { __index = MasterFlowView }

function M.new(player)
  local show_hide_button = create_show_hide_button(player)
  local flow = create_flow(player)
  local self = {
    controller = nil,
    show_hide_button = show_hide_button,
    gui = flow,
    planner_frame = PlannerFrame.new(flow),
    recipe_picker_frame = RecipePickerFrame.new(flow),
  }
  return M.restore(self)
end

function M.restore(self)
  register_event_handlers(self)
  return setmetatable(self, meta)
end

return M
