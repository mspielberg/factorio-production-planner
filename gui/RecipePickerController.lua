local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local RecipePickerFrame = require "gui.RecipePickerFrame"
local RecipePickerFlow = require "gui.RecipePickerFlow"
local VirtualRecipeFlowController = require "gui.VirtualRecipeFlowController"

local function accepted_recipes(force, filter)
  local out = {}
  for _, recipe in pairs(force.recipes) do
    if filter(recipe) then
      out[#out+1] = recipe
    end
  end
  return out
end

local RecipePickerController = {}

function RecipePickerController:on_gui_click(event)
  local element = event.element
  if element.parent and element.parent.name == "groups" then
    self.picker_flow:select_group(element.name)
    return true
  elseif element.type == "sprite-button" then
    event.context.type = "RecipePicker"
    event.context.recipe_name = element.name
  elseif element.name:find("^create_virtual_") then
    event.context.type = "RecipePicker"
  end
end

function RecipePickerController:set_filter(filter)
  local force = self.player.force
  local recipes = accepted_recipes(force, filter)
  self.picker_flow:set_recipes(recipes)
end

function RecipePickerController:show()
  self.picker_frame:show()
end

function RecipePickerController:hide()
  self.virtual_recipe_flow:reset()
  self.picker_frame:hide()
end

local M = {}
local meta = { __index = RecipePickerController }

function M.new(frame, flow, player)
  local self = {
    picker_frame = frame,
    picker_flow = flow,

    virtual_recipe_flow = VirtualRecipeFlowController.new(frame.virtual_recipe_flow),

    player = player,
  }
  return M.restore(self)
end

function M.restore(self)
  RecipePickerFrame.restore(self.picker_frame)
  RecipePickerFlow.restore(self.picker_flow)
  VirtualRecipeFlowController.restore(self.virtual_recipe_flow)
  Dispatcher.register(self, self.picker_frame.gui)
  return setmetatable(self, meta)
end

function M.and_filters(filters)
  return function(recipe)
    for _, filter in ipairs(filters) do
      if not filter(recipe) then
        return false
      end
    end
    return true
  end
end

function M.or_filters(filters)
  return function(recipe)
    for _, filter in ipairs(filters) do
      if filter(recipe) then
        return true
      end
    end
    return false
  end
end

function M.enabled_and_not_hidden_filter()
  return function(recipe)
    return recipe.enabled and not recipe.hidden
  end
end

function M.has_ingredient_filter(name)
  return function(recipe)
    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient.name == name then
        return true
      end
    end
    return false
  end
end

function M.has_product_filter(name)
  return function(recipe)
    for _, product in pairs(recipe.products) do
      if product.name == name then
        return true
      end
    end
    return false
  end
end

return M
