local CraftingMachine = require "CraftingMachine"
local Dispatcher = require "gui.Dispatcher"
local Recipe = require "Recipe"
local RecipeFlow = require "gui.RecipeFlow"

local RecipeFlowController = {}

function RecipeFlowController:set_production_line(production_line)
  self.view.production_line = production_line
  self.view:update()
end

function RecipeFlowController:set_index(index)
  self.index = index
  self.view.index = index
  self.view:update()
end

function RecipeFlowController:prepare_for_link(is_product, item_name)
  self.view:enable_buttons_for_link(is_product, item_name)
end

function RecipeFlowController:complete_link()
  self.view:complete_link()
end

function RecipeFlowController:update()
  self.view:update()
end

function RecipeFlowController:destroy()
  self.view:destroy()
end

-- event handlers

function RecipeFlowController:on_gui_click(event)
  event.context.recipe_index = self.index
end

local M = {}
local meta = { __index = RecipeFlowController }

function M.new(view, index)
  local self = {
    view = view,
    index = index,
    crafting_machine = nil,
  }
  self.view.index = index
  return M.restore(self)
end

function M.restore(self)
  RecipeFlow.restore(self.view)
  Dispatcher.register(self, self.view.gui)
  return setmetatable(self, meta)
end

return M