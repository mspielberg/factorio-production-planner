local inspect = require "inspect"
local RecipePickerView = require "gui.RecipePickerView"

local RecipePickerController = {}

function RecipePickerController:on_group_button(group_name)
  self.view:select_group(group_name)
end

function RecipePickerController:on_recipe_button(recipe_name)
  game.print("selected recipe "..recipe_name)
end

local M = {}
local meta = { __index = RecipePickerController }

local function accepted_recipes(force, filter)
  local out = {}
  for _, recipe in pairs(force.recipes) do
    if filter(recipe) then
      out[#out+1] = recipe
    end
  end
  return out
end

function M.new(parent, force, filter)
  local recipes = accepted_recipes(force, filter)
  log(inspect(recipes))
  local self = {
    view = nil,
  }
  self.view = RecipePickerView.new(self, parent, recipes)
  return M.restore(self)
end

function M.restore(self)
  RecipePickerView.restore(self.view)
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
    for _, product in pairs(recipe.product) do
      if ingredient.name == name then
        return true
      end
    end
    return false
  end
end

return M
