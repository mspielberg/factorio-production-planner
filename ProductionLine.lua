local Recipe = require "Recipe"

local ProductionLine = {}

local function get_recipe_index(self, recipe)
  for i, r in ipairs(self.recipes) do
    if r == recipe then
      return i
    end
  end
end

function ProductionLine:change_recipe(index, name)
  local recipe = self.recipes[index]
  if recipe then
    recipe:set_recipe(name)
  else
    self.recipes[index] = Recipe.new(name)
  end
end

function ProductionLine:remove_recipe(index)
  table.remove(self.recipes, index)
end

function ProductionLine:reorder_recipes(from, to)
  if to < 1 then to = 1 end
  if to > #self.recipes then to = #self.recipes end
  local recipe = self.recipes[from]
  table.remove(self.recipes, from)
  table.insert(self.recipes, to, recipe)
end

function ProductionLine:add_constraint(recipe, item, amount)
  self.constraints[#self.constraints] = {
    recipe = recipe,
    item = item,
    amount = amount,
  }
end

function ProductionLine:link_recipes(r1, r2, item_name)
  self.recipes[r1]:add_constraint(self.recipes[r2], item_name)
end

function ProductionLine:recompute()
  for _, recipe in pairs(self.recipes) do
    recipe:reset()
  end
  for _, constraint in pairs(self.constraints) do
    constraint.recipe:set_rate_by_item(constraint.item, constraint.amount)
  end
end

local M = {}
local meta = { __index = ProductionLine }

function M.new()
  local self = {
    crafting_machines = {},
    recipes = {},
    constraints = {},
  }
  return M.restore(self)
end

function M.restore(self)
  for _, recipe in pairs(self.recipes) do
    Recipe.restore(recipe)
  end
  return setmetatable(self, meta)
end

return M
