local mod_gui = require "mod-gui"
local CraftingMachinePickerFrame = require "gui.CraftingMachinePickerFrame"
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
  local flow = mod_gui.get_frame_flow(player).add{
    name = "planner",
    type = "flow",
    direction = "horizontal",
  }
  flow.style.visible = false
  return flow
end

local MasterFlowView = {}

function MasterFlowView:toggle_show_hide()
  local style = self.gui.style
  style.visible = not style.visible
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
    crafting_machine_picker_frame = CraftingMachinePickerFrame.new(flow),
  }
  return M.restore(self)
end

function M.restore(self)
  PlannerFrame.restore(self.planner_frame)
  RecipePickerFrame.restore(self.recipe_picker_frame)
  return setmetatable(self, meta)
end

return M
