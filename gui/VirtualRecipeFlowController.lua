local Dispatcher = require "gui.Dispatcher"

local VirtualRecipeFlowController = {}
local meta = { __index = VirtualRecipeFlowController }

function VirtualRecipeFlowController:on_gui_click(event)
  local element = event.element
  if element.name == "create_virtual_supply_recipe_button" then
    event.context.virtual_recipe_name = self.view.choose_item_button.elem_value
    event.context.virtual_recipe_rate = tonumber(self.view.rate_field.text)
  elseif element.name == "create_virtual_demand_recipe_button" then
    event.context.virtual_recipe_name = self.view.choose_item_button.elem_value
    event.context.virtual_recipe_rate = -tonumber(self.view.rate_field.text)
  end
end

function VirtualRecipeFlowController:on_gui_text_changed(event)
  local element = event.element
  local rate = event.element.text:gsub("[^0-9%.]", "")
  element.text = rate
end

function VirtualRecipeFlowController:reset()
  self.view:reset()
end

local M = {}

function M.new(view)
  local self = {
    view = view,
  }
  return M.restore(self)
end

function M.restore(self)
  Dispatcher.register(self, self.view.gui)
  return setmetatable(self, meta)
end

return M
