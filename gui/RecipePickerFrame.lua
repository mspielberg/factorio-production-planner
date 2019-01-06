local RecipePickerFlow = require "gui.RecipePickerFlow"

local function create_frame(parent)
  local frame = parent.add{
    name = "recipe_picker_frame",
    type = "frame",
  }
  frame.style.visible = false
  return frame
end

local RecipePickerFrame = {}

local M = {}
local meta = { __index = RecipePickerFrame }

function M.new(parent)
  local frame = create_frame(parent)
  local self = {
    gui = frame,
    picker_flow = RecipePickerFlow.new(frame),
  }
  return M.restore(self)
end

function M.restore(self)
  setmetatable(self, meta)
  return self
end

return M
