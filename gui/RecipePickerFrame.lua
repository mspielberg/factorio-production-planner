local RecipePickerFlow = require "gui.RecipePickerFlow"
local VirtualRecipeFlow = require "gui.VirtualRecipeFlow"

local function create_frame(self, parent)
  local frame = parent.add{
    name = "recipe_picker_frame",
    type = "frame",
    direction = "vertical",
    caption = "Select recipe",
  }
  frame.enabled = false
  frame.visible = false
  self.gui = frame

  frame.add{
    name = "recipe_picker_label",
    type = "label",
    caption = "Select a predefined recipe:",
  }

  self.picker_flow = RecipePickerFlow.new(frame)

  frame.add{
    name = "virtual_recipe_label",
    type = "label",
    caption = "Or create a virtual demand or supply:",
  }

  self.virtual_recipe_flow = VirtualRecipeFlow.new(frame)

  return frame
end

local RecipePickerFrame = {}

function RecipePickerFrame:show()
  self.gui.visible = true
end

function RecipePickerFrame:hide()
  self.gui.visible = false
end

local M = {}
local meta = { __index = RecipePickerFrame }

function M.new(parent)
  local self = {
    gui = nil,
    virtual_recipe_flow = nil,
    picker_flow = nil,
  }
  create_frame(self, parent)
  return M.restore(self)
end

function M.restore(self)
  VirtualRecipeFlow.restore(self.virtual_recipe_flow)
  RecipePickerFlow.restore(self.picker_flow)
  return setmetatable(self, meta)
end

return M
