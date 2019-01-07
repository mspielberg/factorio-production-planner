local mod_gui = require "mod-gui"
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

local MasterFlowView = {}

function MasterFlowView:show_all_recipe_picker()
  self.recipe_picker_frame:set_recipes()
  self.recipe_picker_frame.gui.style.visible = true
end

local M = {}

local meta = { __index = MasterFlowView }

function M.new(player)
  local flow = create_flow(player)
  local self = {
    show_hide_button = create_show_hide_button(player),
    gui = flow,
    planner_frame = PlannerFrame.new(flow),
    recipe_picker_frame = RecipePickerFrame.new(flow),
  }
  return M.restore(self)
end

function M.restore(self)
  PlannerFrame.restore(self.planner_frame)
  RecipePickerFrame.restore(self.recipe_picker_frame)
  return setmetatable(self, meta)
end

return M
