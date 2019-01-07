local Recipe = require "Recipe"

local ProductionLine = {}

local function get_recipe_index(self, recipe)
  for i, r in ipairs(self.recipes) do
    if r == recipe then
      return i
    end
  end
end

function ProductionLine:change_recipe(index, recipe)
  if index then
    self.recipes[index] = recipe
  else
    self.recipes[#self.recipes+1] = recipe
  end
end

function ProductionLine:remove_recipe(index)
  table.remove(self.recipes, index)
end

function ProductionLine:add_constraint(recipe, item, amount)
  self.constraints[#self.constraints] = {
    recipe = recipe,
    item = item,
    amount = amount,
  }
end

function ProductionLine:link_recipes(r1, r2, item_name)
  r1:add_constraint(r2, item_name)
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
  return setmetatable(self, meta)
end

return M
