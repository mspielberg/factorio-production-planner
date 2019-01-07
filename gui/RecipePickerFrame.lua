local RecipePickerFlow = require "gui.RecipePickerFlow"

local function create_frame(parent)
  local frame = parent.add{
    name = "recipe_picker_frame",
    type = "frame",
  }
  frame.enabled = false
  frame.style.visible = false
  return frame
end

local RecipePickerFrame = {}

function RecipePickerFrame:show()
  self.gui.style.visible = true
end

function RecipePickerFrame:hide()
  self.gui.style.visible = false
end

local M = {}
local meta = { __index = RecipePickerFrame }

function M.new(parent)
  local frame = create_frame(parent)
  game.print("frame = "..tostring(frame))
  local self = {
    gui = frame,
    picker_flow = RecipePickerFlow.new(frame),
  }
  return M.restore(self)
end

function M.restore(self)
  RecipePickerFlow.restore(self.picker_flow)
  return setmetatable(self, meta)
end

return M
